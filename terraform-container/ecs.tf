variable "vpc_name" {
  default = "proj-aws-ecs-cicd-vpc-tf"
}

variable "subnet_name_prefix" {
  default = "proj-aws-ecs-cicd-vpc-tf-public-*"
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.9.0"

  cluster_name = "${local.usage_name}-cluster"

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  services = {
    s3-service = {
      subnet_ids = data.aws_subnets.existing_subnets.ids

      cpu    = 1024
      memory = 4096

      container-definitions = {
        s3-service = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "${data.aws_ecr_repository.ecr.repository_url}/${local.usage_name}-ecr-repo:s3-latest"

          port_mappings = [
            {
              name          = "s3-svc"
              containerPort = 5001
              protocol      = "tcp"
            }
          ]
        }
      }
    }

    sqs-service = {
      subnet_ids = data.aws_subnets.existing_subnets.ids

      cpu    = 1024
      memory = 4096

      container-definitions = {
        sqs-service = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "${data.aws_ecr_repository.ecr.repository_url}/${local.usage_name}-ecr-repo:sqs-latest"

          port_mappings = [
            {
              name          = "sqs-svc"
              containerPort = 5002
              protocol      = "tcp"
            }
          ]
        }
      }
    }

  }
}

data "aws_ecr_repository" "ecr" {
  name = "${local.usage_name}-ecr-repo"
}

data "aws_vpc" "existing_vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "existing_subnets" {
  filter {
    name   = "tag:Name"
    values = [var.subnet_name_prefix]
  }
}