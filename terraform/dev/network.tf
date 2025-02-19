module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "${local.app_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-3a", "eu-west-3b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]  # Presentation/web Tier
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]  # App Tier
  database_subnets = ["10.0.5.0/24", "10.0.6.0/24"] # DB Tier

  enable_dns_hostnames = true
  create_igw           = true
  enable_nat_gateway   = true
  single_nat_gateway   = true
  tags = local.tags
}