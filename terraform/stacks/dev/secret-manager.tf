##########################################################
# Aurora PostgreSQL Secret
##########################################################

resource "aws_secretsmanager_secret" "aurora_postgresql_secret" {
  name        = "${var.project_name}-${var.env_name}-aurora-postgresql"
  description = "Aurora postgresql secrets"

  recovery_window_in_days = var.env_name == "prod" ? 30 : 0

  tags = {
    Name        = "${var.project_name}-${var.env_name}-aurora-postgresql"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_secretsmanager_secret_version" "aurora_postgresql_secret_version" {
  secret_id = aws_secretsmanager_secret.aurora_postgresql_secret.id

  secret_string = jsonencode({
    username = "change_me"
    password = "change_me"
    dbname   = "change_me"
  })

  lifecycle {
    ignore_changes = [secret_string, version_stages]
  }
}

data "aws_secretsmanager_secret_version" "aurora_postgresql_current" {
  secret_id = aws_secretsmanager_secret.aurora_postgresql_secret.id

  depends_on = [
    aws_secretsmanager_secret_version.aurora_postgresql_secret_version
  ]
}

locals {
  aurora_postgresql_creds = jsondecode(data.aws_secretsmanager_secret_version.aurora_postgresql_current.secret_string)
}

output "aurora_postgresql_secret_arn" {
  value = aws_secretsmanager_secret.aurora_postgresql_secret.arn
}
