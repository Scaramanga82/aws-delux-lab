##########################################################
# ECS Task Definition
##########################################################

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-${var.env_name}-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.ecs_cpu)
  memory                   = tostring(var.ecs_memory)
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_app.arn
  tags                     = {
    Name        = "${var.project_name}-${var.env_name}-ecs-task"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }

  container_definitions = jsonencode([
    {
      name      = var.project_name
      image     = var.ecs_image
      cpu       = var.ecs_cpu
      memory    = var.ecs_memory
      essential = true

      portMappings = [
        {
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

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/aws/ecs/${var.project_name}-${var.env_name}-app/${var.project_name}"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      readonlyRootFilesystem = false
    }
  ])
}

##########################################################
# ECS Service
##########################################################

resource "aws_ecs_service" "app" {
  name            = "${var.project_name}-${var.env_name}-app"
  cluster         = module.ecs_cluster.cluster_arn
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = module.alb.target_groups["ecs"].arn
    container_name   = var.project_name
    container_port   = var.ecs_container_port
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  force_new_deployment               = true
  wait_for_steady_state              = false

  enable_ecs_managed_tags = true
  tags = {
    Name        = "${var.project_name}-${var.env_name}-ecs-service"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}

##########################################################
# CloudWatch Log Group for ECS Tasks
##########################################################

resource "aws_cloudwatch_log_group" "ecs_app" {
  name              = "/aws/ecs/${var.project_name}-${var.env_name}-app"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-${var.env_name}-ecs-app-logs"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}