resource "aws_sqs_queue" "sqs_service_queue" {
  name = "${local.usage_name}-sqs-svc-queue"
}

output "sqs_queue_url" {
  value = aws_sqs_queue.sqs_service_queue.url
}

output "sqs_queue_name" {
  value = aws_sqs_queue.sqs_service_queue.name
}