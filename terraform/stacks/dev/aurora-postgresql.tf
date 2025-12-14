##########################################################
# RDS Aurora PostgreSQL Cluster
##########################################################

# Read current secret value (client-managed)
data "aws_secretsmanager_secret_version" "aurora_postgresql_secret_current" {
  secret_id = aws_secretsmanager_secret.aurora_postgresql_secret.id
}

# Parse credentials
locals {
  aurora_credentials = jsondecode(data.aws_secretsmanager_secret_version.aurora_postgresql_secret_current.secret_string)
  aurora_username    = local.aurora_credentials.username
  aurora_password    = local.aurora_credentials.password
  aurora_dbname      = local.aurora_credentials.dbname
}

##########################################################
# DB Subnet Group
##########################################################

resource "aws_db_subnet_group" "aurora_postgresql_subnet_group" {
  name       = "${var.project_name}-${var.env_name}-aurora-postgresql-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name        = "${var.project_name}-${var.env_name}-aurora-postgresql-subnet-group"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}

##########################################################
# Aurora PostgreSQL Cluster
##########################################################

module "aurora_postgresql_cluster" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 9.0"

  name              = "${var.project_name}-${var.env_name}-postgresql-cluster"
  engine            = "aurora-postgresql"
  engine_version    = var.aurora_postgresql_engine_version
  storage_encrypted = true

  # Credentials from Secrets Manager
  master_username             = local.aurora_username
  master_password             = local.aurora_password
  database_name               = local.aurora_dbname
  manage_master_user_password = false

  # Network configuration
  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = aws_db_subnet_group.aurora_postgresql_subnet_group.name

  # Security group
  create_security_group = false
  vpc_security_group_ids = [aws_security_group.aurora_postgresql_sg.id]

  # Instance configuration
  instance_class = var.aurora_postgresql_instance_class
  instances = {
    writer  = {}
    reader1 = { instance_type = var.aurora_postgresql_instance_class }
  }

  # Auto-scaling (disabled for now)
  autoscaling_enabled = false

  # Backup configuration
  backup_retention_period      = var.aurora_postgresql_backup_retention_days
  preferred_backup_window      = var.aurora_postgresql_backup_window
  preferred_maintenance_window = var.aurora_postgresql_maintenance_window

  # Monitoring
  enabled_cloudwatch_logs_exports        = ["postgresql"]
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = 7

  # Performance Insights (disabled for dev)
  performance_insights_enabled = false

  # Snapshot
  skip_final_snapshot       = var.env_name != "prod"
  final_snapshot_identifier = var.env_name == "prod" ? "${var.project_name}-${var.env_name}-final" : null

  # Parameter group
  db_parameter_group_name         = aws_db_parameter_group.aurora_postgresql_parameter_group.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_postgresql_cluster_parameter_group.name

  # Apply changes immediately in dev
  apply_immediately = var.env_name != "prod"

  tags = {
    Name        = "${var.project_name}-${var.env_name}-aurora"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}

##########################################################
# DB Parameter Group (Instance-level)
##########################################################

resource "aws_db_parameter_group" "aurora_postgresql_parameter_group" {
  name_prefix = "${var.project_name}-${var.env_name}-aurora-pg-"
  family      = "aurora-postgresql17"
  description = "Aurora PostgreSQL parameter group for ${var.env_name}"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  tags = {
    Name        = "${var.project_name}-${var.env_name}-aurora-pg"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

##########################################################
# Cluster Parameter Group (Cluster-level)
##########################################################

resource "aws_rds_cluster_parameter_group" "aurora_postgresql_cluster_parameter_group" {
  name_prefix = "${var.project_name}-${var.env_name}-aurora-cluster-pg-"
  family      = "aurora-postgresql15"
  description = "Aurora PostgreSQL cluster parameter group for ${var.env_name}"

  parameter {
    name  = "rds.force_ssl"
    value = "0" # Disabled for dev
  }

  parameter {
    name  = "timezone"
    value = "UTC"
  }

  tags = {
    Name        = "${var.project_name}-${var.env_name}-aurora-cluster-pg"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}
