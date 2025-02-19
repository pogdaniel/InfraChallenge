locals {
  env      = "dev"
  app_name = "devops-infra-web-test"
  tags = {
    Environment = local.env
    Project     = local.app_name
    Terraform   = "true"
    Owner       = var.owner
    Repo        = var.repo_tag
  }
}