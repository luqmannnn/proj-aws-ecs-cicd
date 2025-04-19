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
              value = "proj-aws-ecs-cicd-s3-svc-bucket"
            }
          ]
        }
      }
      assign_public_ip                   = true
      deployment_minimum_healthy_percent = 100
      subnet_ids                         = flatten(module.vpc.public_subnets)
      security_group_ids                 = [module.s3_service_sg.security_group_id]
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
              value = "proj-aws-ecs-cicd-sqs-svc-queue"
            }
          ]
        }
      }
      assign_public_ip                   = true
      deployment_minimum_healthy_percent = 100
      subnet_ids                         = flatten(module.vpc.public_subnets)
      security_group_ids                 = [module.sqs_service_sg.security_group_id]
      create_tasks_iam_role              = false
      tasks_iam_role_arn                 = module.sqs_service_task_role.iam_role_arn
    }
  }
}