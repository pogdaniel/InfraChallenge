provider "aws" {
    region = "eu-west-3"
    assume_role {
        role_arn = "arn:aws:iam::777277777771:role/DevOpsAdminRole"
    }
    default_tags {
      tags = local.tags
    }    
}

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
