locals {
  usage_name = "proj-aws-ecs-cicd"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}