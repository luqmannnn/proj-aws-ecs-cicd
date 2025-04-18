module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.usage_name}-vpc-tf"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "prod"
    Created_by = "Luqman"
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_arn" {
  value = module.vpc.vpc_arn
}

output "vpc_priv_subnet" {
  value = module.vpc.private_subnets
}

output "vpc_pub_subnet" {
  value = module.vpc.public_subnets
}