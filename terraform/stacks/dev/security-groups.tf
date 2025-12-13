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

# Ingress rules - Allow PostgreSQL only from private subnet CIDRs
resource "aws_vpc_security_group_ingress_rule" "aurora_postgresql_private_subnets" {
  for_each = toset(var.private_subnets)

  security_group_id = aws_security_group.aurora_postgresql_sg.id
  description       = "Allow PostgreSQL from private subnets"

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"
  cidr_ipv4   = each.value
}

output "aurora_postgresql_sg_id" {
  description = "ID of Aurora PostgreSQL security group"
  value       = aws_security_group.aurora_postgresql_sg.id
}