resource "aws_ecr_repository" "s3_ecr" {
  name         = "${local.usage_name}-s3-ecr"
  force_delete = true
}

resource "aws_ecr_repository" "sqs_ecr" {
  name         = "${local.usage_name}-sqs-ecr"
  force_delete = true
}

output "s3_ecr_url" {
  value = aws_ecr_repository.s3_ecr.repository_url
}

output "sqs_ecr_url" {
  value = aws_ecr_repository.sqs_ecr.repository_url
}