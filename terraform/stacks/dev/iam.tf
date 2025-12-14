##########################################################
# ECS Task Execution Role
##########################################################

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project_name}-${var.env_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.env_name}-ecs-task-execution-role"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}

# Attach AWS managed policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Custom policy for Secrets Manager access
resource "aws_iam_role_policy" "ecs_secrets_access" {
  name = "${var.project_name}-${var.env_name}-ecs-task-execution-secrets-access"
  role        = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          aws_secretsmanager_secret.aurora_postgresql_secret.arn
        ]
      }
    ]
  })
}

# ECR access policy
resource "aws_iam_role_policy" "ecs_ecr_access" {
  name_prefix = "${var.project_name}-${var.env_name}-ecs-ecr-access"
  role        = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

##########################################################
# ECS Task Role (for application permissions)
##########################################################

resource "aws_iam_role" "ecs_task_app" {
  name = "${var.project_name}-${var.env_name}-ecs-task-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.env_name}-ecs-task-app-role"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}

# Application can access Secrets Manager at runtime
resource "aws_iam_role_policy" "ecs_task_app_secrets" {
  name = "${var.project_name}-${var.env_name}-ecs-task-app-secrets-access"
  role        = aws_iam_role.ecs_task_app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          aws_secretsmanager_secret.aurora_postgresql_secret.arn
        ]
      }
    ]
  })
}

# Output - ecs task execution role arn
output "ecs_task_execution_role_arn" {
  description = "ARN of ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.arn
}

# Output - ecs task role arn
output "ecs_task_role_arn" {
  description = "ARN of ECS task role"
  value       = aws_iam_role.ecs_task_app.arn
}
