variable "vpc_name" {
  default = "proj-aws-ecs-cicd-vpc-tf"
}

variable "subnet_name_prefix" {
  default = "proj-aws-ecs-cicd-vpc-tf-public-*"
}

resource "aws_s3_bucket" "s3_service_bucket" {
  bucket = "jaz-s3-service-bkt"
}

resource "aws_sqs_queue" "sqs_service_queue" {
  name = "jaz-sqs-service-queue"
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.9.0"

  cluster_name = "${local.usage_name}-ecs-cluster"

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  services = {
    "${local.usage_name}-s3-svc" = {
      cpu    = 512
      memory = 1024
      container_definitions = {
        "${local.usage_name}-s3-svc-container" = {
          essential = true
          image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.usage_name}-s3-ecr:latest"
          port_mappings = [
            {
              containerPort = 5001
              protocol      = "tcp"
            }
          ]
          environment = [
            {
              name  = "AWS_REGION"
              value = "us-east-1"
            },
            {
              name  = "BUCKET_NAME"
              value = "${local.usage_name}-s3-svc-bucket"
            }
          ]
        }
      }
      assign_public_ip                   = true
      deployment_minimum_healthy_percent = 100
      subnet_ids                         = flatten(data.aws_subnets.existing_subnets.ids)
      security_group_ids                 = [data.aws_security_group.s3_sg.id]
      create_tasks_iam_role              = false
      tasks_iam_role_arn                 = module.s3_service_task_role.iam_role_arn
    }

    "${local.usage_name}-sqs-svc" = {
      cpu    = 512
      memory = 1024
      container_definitions = {
        "${local.usage_name}-sqs-svc-container"= {
          essential = true
          image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.usage_name}-sqs-ecr:latest"
          port_mappings = [
            {
              containerPort = 5002
              protocol      = "tcp"
            }
          ]
          environment = [
            {
              name  = "AWS_REGION"
              value = "us-east-1"
            },
            {
              name  = "QUEUE_URL"
              value = "${local.usage_name}-sqs-svc-queue"
            }
          ]
        }
      }
      assign_public_ip                   = true
      deployment_minimum_healthy_percent = 100
      subnet_ids                         = flatten(data.aws_subnets.existing_subnets.ids)
      security_group_ids                 = [data.aws_security_group.sqs_sg.id]
      create_tasks_iam_role              = false
      tasks_iam_role_arn                 = module.sqs_service_task_role.iam_role_arn
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

data "aws_security_group" "sqs_sg" {
  filter {
    name = "tag:Name"
    values = ["${local.usage_name}-sqs-ecs-sg"]
  }
}

data "aws_security_group" "s3_sg" {
  filter {
    name = "tag:Name"
    values = ["${local.usage_name}-s3-ecs-sg"]
  }
}