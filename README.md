# 🚀 AWS 3-Tier Architecture Infra Challenge | Terraform Edition | Simple Web Server with AGS

Simple three-tier architecture using AWS Free Tier resources that's both *scalable* and *secure* 

## Architecture Overview
```
[Internet]
  |
[Application Load Balancer]
  |
[Auto Scaling Group] - Web Tier (EC2 instances)
  |
[Application Tier] - (Future microservices)
  |
[Database Tier] - RDS PostgreSQL
```

## Components
- **Network**: VPC with public/private subnets, NAT Gateway
- **Web Tier**: Auto-scaled EC2 instances behind ALB
- **Data Tier**: Managed PostgreSQL with Secrets Manager
- **Security**: IAM roles, Security Groups, encrypted storage


🛠️ Getting Started
Pre-reqs:

AWS account (free tier)

Terraform v1.3+

Coffee ☕ 

1. Initialize Terraform:
```bash
terraform init
terraform plan # Please always check the plan!
terraform apply
```

2. Grab the ALB DNS from outputs:
terraform output alb_dns_name

Pro Tip: Wanna SSH? Not the case, we are using SSM (way safer than open ports)


🌟 Cool Features
Auto-Healing Web Servers 🤖 - Auto Scaling groups replaces unhealthy instances

Encrypted RDS 🔐 - Secure data

Cost Tracking 💸 - Tags help track spend

Repo Tagging 🏷️ - Most resources links back here

## Next Steps
- Add monitoring (CloudWatch, OpenTelemetry with Grafana LGTM stack)
- Implement CI/CD pipeline (Github actions, Auto-deploy on Git push)
- Add application tier (Lambda/ECS)
- Enable VPC Flow Logs
- Better availability cross regions
- Configure backup/DR strategy
- Implement WAF for ALB
- Cost Budgets (prevent surprise bills)

**Important**: This is a minimal setup - production environments require additional security, AWS SSO,  hardening and monitoring.
