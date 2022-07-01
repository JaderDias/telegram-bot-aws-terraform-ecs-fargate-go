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
  container_definitions = templatefile("./app.json.tpl", {
    aws_ecr_repository = aws_ecr_repository.repo.repository_url
    tag                = "latest"
    app_port           = 80
    region             = "${var.region}"
    prefix             = "${var.prefix}"
    envvars            = var.envvars
    port               = var.port
    telegram_bot_token = var.telegram_bot_token
  })
  tags = {
    Environment = "staging"
    Application = "${var.prefix}-app"
  }
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

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role]

  tags = {
    Environment = "staging"
    Application = "${var.prefix}-app"
  }
}
