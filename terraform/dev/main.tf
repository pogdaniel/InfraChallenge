##
# Prequisites

resource "random_password" "db" {
  length  = 64
  special = false
}

resource "aws_secretsmanager_secret" "db" {
  name = "${local.app_name}-db-creds"
  tags = merge(local.tags, {
    Tier = "ImproveSecurity"
  })  
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.db_username,
    password = random_password.db.result
  })
}


# RDS PostgreSQL with SSM/Secrets Manager

module "db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 8.0"

  name           = "${local.app_name}-RDS-AURORA-POSTGRES-DB"
  engine         = "aurora-postgresql"
  instance_class = "db.t3.medium" # Free tier eligible

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.database_subnets

  master_username = var.db_username
  manage_master_user_password = false
  master_password = random_password.db.result

  storage_encrypted = true
  tags = merge(local.tags, {
    Tier = "database"
    Name = "${local.app_name}-rds"
  })  
}
