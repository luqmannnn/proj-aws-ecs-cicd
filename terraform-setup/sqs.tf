resource "aws_sqs_queue" "sqs_service_queue" {
  name = "${local.usage_name}-sqs-svc-queue"
}

