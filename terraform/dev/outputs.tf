##
# implementation 1 output for apache web servers
output "alb_dns_name" {
  value = module.alb.lb_dns_name
}

output "rds_endpoint" {
  value = module.db.cluster_endpoint
}

output "web_instance_ids" {
  description = "IDs of EC2 instances"
  value       = values(module.web_servers)[*].id
}

## implementation 2 for Lambda severless outputs
# 
output "api_lambda_arn" {
  value = module.api_lambda.lambda_function_arn
}

output "cloudfront_url" {
  value = module.react_hosting.cloudfront_distribution_domain_name
}

output "api_endpoint" {
  value = module.api_gateway.apigatewayv2_api_api_endpoint
}

output "cognito_pool_id" {
  value = aws_cognito_user_pool.users.id
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.react_client.id
}