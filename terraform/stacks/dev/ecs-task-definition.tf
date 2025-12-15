##########################################################
# ECS Task Definition & Service
##########################################################

module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "6.10.0"

  name        = "${var.project_name}-${var.env_name}-app"
  cluster_arn = module.ecs_cluster.cluster_arn

  # Fargate configuration
  cpu    = var.ecs_cpu
  memory = var.ecs_memory

  # ✅ ISPRAVLJENO - Map format sa ispravnim port_mappings
  container_definitions = {
    (var.project_name) = {
      cpu       = var.ecs_cpu
      memory    = var.ecs_memory
      essential = true
      image     = var.ecs_image

      enable_cloudwatch_logging = true
      
      port_mappings = [
        {
          name          = var.project_name
          containerPort = var.ecs_container_port
          protocol      = "tcp"
        }
      ]

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

  # Service configuration
  service_connect_configuration = {
    enabled = false
  }
  
  # Load balancer
  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["ecs"].arn
      container_name   = var.project_name
      container_port   = var.ecs_container_port
    }
  }

  # Network configuration
  subnet_ids = module.vpc.private_subnets
  
  # Security group
  create_security_group = false
  security_group_ids    = [aws_security_group.ecs_tasks.id]

  # IAM roles
  tasks_iam_role_arn        = aws_iam_role.ecs_task_app.arn
  task_exec_iam_role_arn    = aws_iam_role.ecs_task_execution.arn
  create_task_exec_iam_role = false
  create_tasks_iam_role     = false
  create_task_definition    = true

  # Service settings
  desired_count                      = var.ecs_desired_count
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 60
  
  # Auto-scaling
  enable_autoscaling = false
  
  # Force new deployment on changes
  force_new_deployment  = true
  wait_for_steady_state = false

  tags = {
    Name        = "${var.project_name}-${var.env_name}-ecs-service"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}

##########################################################
# Data source for current region
##########################################################

data "aws_region" "current" {}
