##########################################################
# ECS Cluster & Service (Combined)
##########################################################

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "6.10.0"

  cluster_name = "${var.project_name}-${var.env_name}-ecs-cluster"

  # Cluster configuration
  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.ecs_cluster.name
      }
    }
  }

  # Fargate capacity providers
  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 1
      base   = 1
    }
    FARGATE_SPOT = {
      weight = 0
    }
  }

  services = {
    app = {
      cpu    = var.ecs_cpu
      memory = var.ecs_memory

      # Container definitions
      container_definitions = {
        (var.project_name) = {
          cpu       = var.ecs_cpu
          memory    = var.ecs_memory
          essential = true
          image     = var.ecs_image

          portMappings = [
            {
              name          = var.project_name
              containerPort = var.ecs_container_port
              protocol      = "tcp"
            }
          ]

          enable_cloudwatch_logging = true

          environment = [
            {
              name  = "ENVIRONMENT"
              value = var.env_name
            },
            {
              name  = "PORT"
              value = tostring(var.ecs_container_port)
            }
          ]

          secrets = [
            {
              name      = "DB_HOST"
              valueFrom = "${aws_secretsmanager_secret.aurora_postgresql_secret.arn}:host::"
            },
            {
              name      = "DB_PORT"
              valueFrom = "${aws_secretsmanager_secret.aurora_postgresql_secret.arn}:port::"
            },
            {
              name      = "DB_NAME"
              valueFrom = "${aws_secretsmanager_secret.aurora_postgresql_secret.arn}:dbname::"
            },
            {
              name      = "DB_USERNAME"
              valueFrom = "${aws_secretsmanager_secret.aurora_postgresql_secret.arn}:username::"
            },
            {
              name      = "DB_PASSWORD"
              valueFrom = "${aws_secretsmanager_secret.aurora_postgresql_secret.arn}:password::"
            }
          ]

          readonly_root_filesystem = false
        }
      }

      # Load balancer
      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups["ecs"].arn
          container_name   = var.project_name
          container_port   = var.ecs_container_port
        }
      }

      # Network
      subnet_ids = module.vpc.private_subnets

      # Security group rules (inline)
      security_group_rules = {
        alb_ingress = {
          type                     = "ingress"
          from_port                = var.ecs_container_port
          to_port                  = var.ecs_container_port
          protocol                 = "tcp"
          description              = "Allow traffic from ALB"
          source_security_group_id = module.alb.security_group_id
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "Allow all outbound"
        }
      }

      # IAM roles
      tasks_iam_role_arn     = aws_iam_role.ecs_task_app.arn
      task_exec_iam_role_arn = aws_iam_role.ecs_task_execution.arn

      # Service settings
      desired_count                      = var.ecs_desired_count
      deployment_minimum_healthy_percent = 50
      deployment_maximum_percent         = 200
      health_check_grace_period_seconds  = 60
      force_new_deployment               = true
      wait_for_steady_state              = false
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.env_name}-ecs"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}

##########################################################
# CloudWatch Log Group for Cluster
##########################################################

resource "aws_cloudwatch_log_group" "ecs_cluster" {
  name              = "/aws/ecs/${var.project_name}-${var.env_name}-cluster"
  retention_in_days = 90

  tags = {
    Name        = "${var.project_name}-${var.env_name}-ecs-cluster-logs"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}

##########################################################
# Data source for current region
##########################################################

data "aws_region" "current" {}
