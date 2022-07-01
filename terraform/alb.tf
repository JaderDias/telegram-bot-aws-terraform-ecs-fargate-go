resource "aws_lb_target_group" "my_api" {
  name        = "my-api"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.default.id
  health_check {
    enabled = true
    path    = "/health"
  }
  depends_on = [aws_alb.my_api]
}

resource "aws_alb" "my_api" {
  name               = "my-api-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [for id in data.aws_subnets.default.ids : id]
  security_groups = [
    aws_security_group.ecs_tasks.id,
  ]
}

resource "aws_alb_listener" "my_api_http" {
  load_balancer_arn = aws_alb.my_api.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_api.arn
  }
}

output "alb_url" {
  value = "http://${aws_alb.my_api.dns_name}"
}
