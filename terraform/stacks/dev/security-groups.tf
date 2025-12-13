##########################################################
# Security Group - Aurora PostgreSQL
##########################################################

resource "aws_security_group" "aurora_postgresql_sg" {
  name_prefix = "${var.project_name}-${var.env_name}-aurora-postgresql-"
  description = "Security group for Aurora PostgreSQL"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.env_name}-aurora-postgresql-sg"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Ingress rules - allow PostgreSQL only from private subnets
resource "aws_security_group_rule" "aurora_postgresql_private_subnets" {
  for_each          = toset(module.vpc.private_subnet_cidrs)
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = [each.value]
  security_group_id = aws_security_group.aurora_postgresql_sg.id
}

output "aurora_postgresql_sg_id" {
  description = "ID of Aurora PostgreSQL security group"
  value       = aws_security_group.aurora_postgresql_sg.id
}
