module "s3_service_task_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.52.1"

  trusted_role_services = [
    "ecs-tasks.amazonaws.com"
  ]

  role_requires_mfa = false

  create_role = true
  role_name   = "${local.usage_name}-s3-task-role"
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]
}

module "sqs_service_task_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.52.1"

  trusted_role_services = [
    "ecs-tasks.amazonaws.com"
  ]

  role_requires_mfa = false

  create_role = true
  role_name   = "${local.usage_name}-sqs-task-role"
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
  ]
}