## This file is used to define a new serverless 3-tier architecture infrastructure
#
# Frontend Infra (react app)

module "react_hosting" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.2.1"

  comment = "React app distribution"
  enabled = true

  origin = {
    s3 = {
      domain_name = module.react_bucket.s3_bucket_bucket_regional_domain_name
      s3_origin_config = {
        origin_access_identity = aws_cloudfront_origin_access_identity.react_oai.cloudfront_access_identity_path
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
  }

  viewer_certificate = {
    cloudfront_default_certificate = true
  }
}

module "react_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket = "${local.app_name}-react-app"
  acl    = "private"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}

## This resource is only an ideea of how to create an OAI/CloudFront distribution

resource "aws_cloudfront_origin_access_identity" "react_oai" {
  comment = "React app OAI"
}

# Backend Infra

module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "2.2.2"

  name          = "${local.app_name}-api"
  protocol_type = "HTTP"
  
  integrations = {
    "ANY /{proxy+}" = {
      integration_type = "AWS_PROXY"
      integration_uri  = module.api_lambda.lambda_function_arn
    }
  }
}

resource "aws_iam_policy" "lambda_db_access" {
  name        = "${local.app_name}-lambda-db-access"
  description = "RDS access policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["rds-db:connect"]
        Effect   = "Allow"
        Resource = module.db.cluster_arn
      }
    ]
  })
}

module "api_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "6.0.1"

  function_name = "${local.app_name}-api-handler"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  source_path   = "./lambda/src"
  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.lambda_sg.security_group_id]

  environment_variables = {
    DB_ENDPOINT = module.db.cluster_endpoint
    DB_NAME     = "${local.app_name}_db"
  }


  policies = [
    aws_iam_policy.lambda_db_access.arn,
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  ]
}

module "lambda_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "${local.app_name}-lambda-sg"
  description = "Lambda security group"
  vpc_id      = module.vpc.vpc_id

  egress_rules = ["all-all"]
}

# Auth Infra
resource "aws_cognito_user_pool" "users" {
  name = "${local.app_name}-user-pool"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }
}

resource "aws_cognito_user_pool_client" "react_client" {
  name         = "react-web-client"
  user_pool_id = aws_cognito_user_pool.users.id
}

resource "aws_cognito_user_pool_domain" "auth_domain" {
  domain       = "${local.app_name}-auth"
  user_pool_id = aws_cognito_user_pool.users.id
}

## WIP
# module "serverless_lambda" {
#   source  = "git::https://github.com/terraform-aws-modules/terraform-aws-lambda.git"
#   # or registry reference if available
#   version = "~> x.x"

#   # pass variables: function name, runtime, handler, code S3 location or local path
#   function_name = var.lambda_tickets_function_name
#   handler       = "index.handler"
#   runtime       = "nodejs14.x"
#   ...
# }

# module "serverless_apigateway" {
#   source  = "git::https://github.com/terraform-aws-modules/terraform-aws-api-gateway.git"
#   version = "~> x.x"

#   # pass variables for your REST API name, stage, etc.
#   # define integration with module.serverless_lambda.function_arn
#   ...
# }

# module "serverless_cognito" {
#   source  = "git::https://github.com/terraform-aws-modules/terraform-aws-cognito-user-pool.git"
#   version = "~> x.x"

#   # pass variables for user pool name, etc
# }