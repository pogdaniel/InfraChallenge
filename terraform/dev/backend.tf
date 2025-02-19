terraform {
    backend "s3" {
        bucket         = "your-s3-bucket-name"
        key            = "path/to/terraform.tfstate"
        region         = "your-aws-region"
        dynamodb_table = "terraform-lock-table-dev"
    }
}

resource "aws_dynamodb_table" "terraform_lock" {
    name         = "terraform-lock-table-dev"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }

    tags = {
        Environment = "dev"
        Name        = "TerraformLockTable"
    }
}