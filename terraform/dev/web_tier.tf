##
# SG for ALB
module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${local.app_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id

  ingress_rules        = ["http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules         = ["all-all"]
  
}

# App Load Balancer
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name               = "${local.app_name}-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.alb_sg.security_group_id]

  target_groups = [
    {
      name_prefix      = "web-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = merge(local.tags, {
    Tier = "web"
    Name = "${local.app_name}-alb"
  })
}

# SG for Apache Web Servers
module "web_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${local.app_name}-web-sg"
  description = "Security group for web servers"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]

  egress_rules = ["all-all"]
}

# EC2 in Private Subnets
module "web_servers" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.0"

  for_each = toset(["eu-west-3a", "eu-west-3b"])

  name = "${local.app_name}-web-${each.key}"

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [module.web_sg.security_group_id]
  subnet_id              = module.vpc.private_subnets[index(["eu-west-3a", "eu-west-3b"], each.key)]
  
  iam_instance_profile = aws_iam_instance_profile.ssm.name
  user_data            = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd.x86_64
    systemctl start httpd.service
    systemctl enable httpd.service

    TOKEN=$(curl --request PUT "http://169.254.169.254/latest/api/token" --header "X-aws-ec2-metadata-token-ttl-seconds: 3600")

    instanceId=$(curl -s http://169.254.169.254/latest/meta-data/instance-id --header "X-aws-ec2-metadata-token: $TOKEN")
    instanceAZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone --header "X-aws-ec2-metadata-token: $TOKEN")
    privHostName=$(curl -s http://169.254.169.254/latest/meta-data/local-hostname --header "X-aws-ec2-metadata-token: $TOKEN")
    privIPv4=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4 --header "X-aws-ec2-metadata-token: $TOKEN")

    echo '<!DOCTYPE html>' > /var/www/html/index.html
    echo '<html><head><title>EC2 Metadata</title>' >> /var/www/html/index.html
    echo '<style>body {font-family: Verdana, sans-serif; font-size: 18px;}</style></head>' >> /var/www/html/index.html
    echo '<body>' >> /var/www/html/index.html
    echo '<center><h1>AWS Linux VM Deployed with Terraform</h1>' >> /var/www/html/index.html
    echo '<h2>EC2 Instance Metadata</h2>' >> /var/www/html/index.html
    echo '<p><b>Instance ID:</b> '"$instanceId"'</p>' >> /var/www/html/index.html
    echo '<p><b>Availability Zone:</b> '"$instanceAZ"'</p>' >> /var/www/html/index.html
    echo '<p><b>Private Hostname:</b> '"$privHostName"'</p>' >> /var/www/html/index.html
    echo '<p><b>Private IPv4:</b> '"$privIPv4"'</p>' >> /var/www/html/index.html
    echo '</center></body></html>' >> /var/www/html/index.html
  EOF

  tags = merge(local.tags, {
    Tier = "web"
  })
}


##
# ASG Config

resource "aws_autoscaling_group" "web" {
  name_prefix          = "${local.app_name}-web-asg-"
  min_size             = 2
  max_size             = 2
  desired_capacity     = 2
  vpc_zone_identifier  = module.vpc.private_subnets
  health_check_type    = "EC2"

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
}

# Update launch template user_data
resource "aws_launch_template" "web" {
  # ... other configuration ...

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd.x86_64
    systemctl start httpd.service
    systemctl enable httpd.service

    TOKEN=$(curl --request PUT "http://169.254.169.254/latest/api/token" --header "X-aws-ec2-metadata-token-ttl-seconds: 3600")

    instanceId=$(curl -s http://169.254.169.254/latest/meta-data/instance-id --header "X-aws-ec2-metadata-token: $TOKEN")
    instanceAZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone --header "X-aws-ec2-metadata-token: $TOKEN")
    privHostName=$(curl -s http://169.254.169.254/latest/meta-data/local-hostname --header "X-aws-ec2-metadata-token: $TOKEN")
    privIPv4=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4 --header "X-aws-ec2-metadata-token: $TOKEN")

    echo '<!DOCTYPE html>' > /var/www/html/index.html
    echo '<html><head><title>EC2 Metadata</title>' >> /var/www/html/index.html
    echo '<style>body {font-family: Verdana, sans-serif; font-size: 18px;}</style></head>' >> /var/www/html/index.html
    echo '<body>' >> /var/www/html/index.html
    echo '<center><h1>AWS Linux VM Deployed with Terraform</h1>' >> /var/www/html/index.html
    echo '<h2>EC2 Instance Metadata</h2>' >> /var/www/html/index.html
    echo '<p><b>Instance ID:</b> '"$instanceId"'</p>' >> /var/www/html/index.html
    echo '<p><b>Availability Zone:</b> '"$instanceAZ"'</p>' >> /var/www/html/index.html
    echo '<p><b>Private Hostname:</b> '"$privHostName"'</p>' >> /var/www/html/index.html
    echo '<p><b>Private IPv4:</b> '"$privIPv4"'</p>' >> /var/www/html/index.html
    echo '</center></body></html>' >> /var/www/html/index.html
  EOF
  )
}
