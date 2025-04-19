terraform {
  backend "s3" {
    bucket = "sctp-ce9-tfstate"
    key    = "proj-aws-ecs-cicd-setup.tfstate"
    region = "us-east-1"
  }
}