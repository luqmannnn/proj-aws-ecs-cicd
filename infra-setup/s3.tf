resource "aws_s3_bucket" "s3_service_bucket" {
  bucket = "${local.usage_name}-s3-svc-bucket"
}

output "bucket_name" {
  value = aws_s3_bucket.s3_service_bucket.bucket
}