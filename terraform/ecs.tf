resource "aws_ecs_cluster" "staging" {
  name = "${var.prefix}-cluster"
}

resource "aws_ecr_repository" "repo" {
  name = "${var.prefix}/runner"
}

resource "aws_ecs_task_definition" "service" {
  family                   = "${var.prefix}-task-family"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = 256
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
    {
      name      = "${var.prefix}-app"
      command   = [var.telegram_bot_token]
      image     = "${aws_ecr_repository.repo.repository_url}:latest"
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = "${var.region}"
          awslogs-stream-prefix = "${var.prefix}-service"
          awslogs-group         = "${var.prefix}-log-group"
        }
      }
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      cpu = 1
      ulimits = [
        {
          name      = "nofile"
          softLimit = 65536
          hardLimit = 65536
        }
      ]
      mountPoints = []
      memory      = 2048
      volumesFrom = []
    }
  ])
  tags = {
    Environment = "staging"
    Application = "${var.prefix}-app"
  }
  depends_on = [
    aws_ecr_repository.repo,
  ]
}

resource "aws_ecs_service" "staging" {
  name            = "${var.prefix}-service"
  cluster         = aws_ecs_cluster.staging.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = data.aws_subnets.default.ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.my_api.arn
    container_name   = "${var.prefix}-app"
    container_port   = 3000
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role]

  tags = {
    Environment = "staging"
    Application = "${var.prefix}-app"
  }
}
