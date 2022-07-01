variable "prefix" {
  description = "prefix prepended to names of all resources created"
  default     = "telegram-bot-go-fargate"
}

variable "port" {
  description = "port the container exposes, that the load balancer should forward port 80 to"
  default     = "4000"
}

variable "source_path" {
  description = "source path for project"
  default     = "./project"
}

variable "tag" {
  description = "tag to use for our new docker image"
  default     = "latest"
}

variable "envvars" {
  type        = map(string)
  description = "variables to set in the environment of the container"
  default = {
  }
}

resource "random_pet" "this" {
  length = 2
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

resource "aws_cloudwatch_log_group" "dummyapi" {
  name = "${var.prefix}-log-group"

  tags = {
    Environment = "staging"
    Application = "${var.prefix}-app"
  }
}

resource "null_resource" "generate_dictionary" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    working_dir = "../"
    command     = "./generate_dictionary.sh"
    interpreter = ["bash", "-c"]
  }
}

resource "null_resource" "push_docker_image" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    working_dir = "../"
    command     = "./push_docker_image.sh ${var.source_path} ${aws_ecr_repository.repo.repository_url} ${var.tag} ${data.aws_caller_identity.current.account_id}"
    interpreter = ["bash", "-c"]
  }
  depends_on = [
    resource.null_resource.generate_dictionary
  ]
}
