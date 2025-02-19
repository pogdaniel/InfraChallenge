##
# Storing Terraform State in S3 and Locking with DynamoDB
# This code shows how to configure Terraform to store its state in S3 bucket 
# and lock state with a DynamoDB table
# This is the best practice for Terraform SM
#  

terraform {
  backend "s3" {
    bucket         = "infra-devops-backend-tf-state"
    key            = "three-tier-app/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "terraform-lock-table-dev"
    encrypt        = true
  }
}

# state Locking Infra
resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-lock-table-dev"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(local.tags, {
    Component = "StateLock"
  })
}


# state Storage Infra
module "tf_state_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket = "infra-devops-backend-tf-state"
  acl    = "private"

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = merge(local.tags, {
    Component = "StateStorage"
  })
}