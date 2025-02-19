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



## 📐 Architecture Snapshot  
```mermaid  
graph TD  
    A[User] --> B((ALB))  
    B --> C[EC2 Web Tier]  
    C --> D[RDS PostgreSQL]  
    C --> E[SSM Access]  
    style A fill:#4CAF50,stroke:#388E3C  
    style B fill:#2196F3,stroke:#0D47A1  
    style C fill:#FF9800,stroke:#EF6C00  
    style D fill:#9C27B0,stroke:#6A1B9A  
    style E fill:#607D8B,stroke:#37474F  


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
- Add monitoring (CloudWatch)
- Implement CI/CD pipeline
- Add application tier (Lambda/ECS)
- Enable VPC Flow Logs
- Configure backup/DR strategy
- Implement WAF for ALB

**Important**: This is a minimal setup - production environments require additional security, AWS SSO,  hardening and monitoring.
