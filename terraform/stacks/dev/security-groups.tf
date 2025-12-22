# ##########################################################
# # Security Group - Aurora PostgreSQL
# ##########################################################

# resource "aws_security_group" "aurora_postgresql_sg" {
#   name        = "${var.project_name}-${var.env_name}-aurora-postgresql-sg"
#   description = "Security group for Aurora PostgreSQL"
#   vpc_id      = module.vpc.vpc_id

#   tags = {
#     Name        = "${var.project_name}-${var.env_name}-aurora-postgresql-sg"
#     Project     = var.project_name
#     Environment = var.env_name
#     ManagedBy   = "Terraform"
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# # Ingress - from ECS tasks
# resource "aws_vpc_security_group_ingress_rule" "rds_from_ecs" {
#   security_group_id = aws_security_group.aurora_postgresql_sg.id
#   description       = "Allow PostgreSQL from ECS tasks"

#   from_port                    = 5432
#   to_port                      = 5432
#   ip_protocol                  = "tcp"
#   referenced_security_group_id = aws_security_group.ecs_tasks.id
# }

# # Output - aurora postgresql sg id
# output "aurora_postgresql_sg_id" {
#   description = "ID of Aurora PostgreSQL security group"
#   value       = aws_security_group.aurora_postgresql_sg.id
# }

# ##########################################################
# # Security Group - Application Load Balancer
# ##########################################################

# resource "aws_security_group" "alb" {
#   name        = "${var.project_name}-${var.env_name}-alb-sg"
#   description = "Security group for Application Load Balancer"
#   vpc_id      = module.vpc.vpc_id

#   tags = {
#     Name        = "${var.project_name}-${var.env_name}-alb-sg"
#     Project     = var.project_name
#     Environment = var.env_name
#     ManagedBy   = "Terraform"
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# # Ingress - HTTP from internet
# resource "aws_vpc_security_group_ingress_rule" "alb_http" {
#   security_group_id = aws_security_group.alb.id
#   description       = "Allow HTTP from internet"

#   from_port   = 80
#   to_port     = 80
#   ip_protocol = "tcp"
#   cidr_ipv4   = "0.0.0.0/0"
# }

# # Ingress - HTTPS from internet
# resource "aws_vpc_security_group_ingress_rule" "alb_https" {
#   security_group_id = aws_security_group.alb.id
#   description       = "Allow HTTPS from internet"

#   from_port   = 443
#   to_port     = 443
#   ip_protocol = "tcp"
#   cidr_ipv4   = "0.0.0.0/0"
# }

# # Egress - to ECS tasks
# resource "aws_vpc_security_group_egress_rule" "alb_to_ecs" {
#   security_group_id = aws_security_group.alb.id
#   description       = "Allow traffic to ECS tasks"

#   from_port                    = var.ecs_container_port
#   to_port                      = var.ecs_container_port
#   ip_protocol                  = "tcp"
#   referenced_security_group_id = aws_security_group.ecs_tasks.id
# }

# # Output - alb security group id
# output "alb_security_group_id" {
#   description = "ID of ALB security group"
#   value       = aws_security_group.alb.id
# }

# ##########################################################
# # Security Group - ECS Tasks
# ##########################################################

# resource "aws_security_group" "ecs_tasks" {
#   name        = "${var.project_name}-${var.env_name}-ecs-tasks-sg"
#   description = "Security group for ECS tasks"
#   vpc_id      = module.vpc.vpc_id

#   tags = {
#     Name        = "${var.project_name}-${var.env_name}-ecs-tasks-sg"
#     Project     = var.project_name
#     Environment = var.env_name
#     ManagedBy   = "Terraform"
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# # Ingress - from ALB
# resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
#   security_group_id = aws_security_group.ecs_tasks.id
#   description       = "Allow traffic from ALB"

#   from_port                    = var.ecs_container_port
#   to_port                      = var.ecs_container_port
#   ip_protocol                  = "tcp"
#   referenced_security_group_id = aws_security_group.alb.id
# }

# # Egress - to RDS
# resource "aws_vpc_security_group_egress_rule" "ecs_to_rds" {
#   security_group_id = aws_security_group.ecs_tasks.id
#   description       = "Allow traffic to RDS"

#   from_port                    = 5432
#   to_port                      = 5432
#   ip_protocol                  = "tcp"
#   referenced_security_group_id = aws_security_group.aurora_postgresql_sg.id
# }

# # Egress - to internet (for updates, ECR pulls, etc.)
# resource "aws_vpc_security_group_egress_rule" "ecs_to_internet" {
#   security_group_id = aws_security_group.ecs_tasks.id
#   description       = "Allow outbound internet access"

#   ip_protocol = "-1"
#   cidr_ipv4   = "0.0.0.0/0"
# }

# # Output - ecs task security group id
# output "ecs_tasks_security_group_id" {
#   description = "ID of ECS tasks security group"
#   value       = aws_security_group.ecs_tasks.id
# }