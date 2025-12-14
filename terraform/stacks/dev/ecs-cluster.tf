##########################################################
# ECS Cluster
##########################################################

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "6.10.0"

  cluster_name  = "${var.project_name}-${var.env_name}-ecs-cluster"

  autoscaling_capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 1
    },
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 0
    }
  ]

  tags = {
    Name        = "${var.project_name}-${var.env_name}-ecs-cluster"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}

##########################################################
# CloudWatch Log Group
##########################################################

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}-${var.env_name}"
  retention_in_days = var.env_name == "prod" ? 30 : 7

  tags = {
    Name        = "${var.project_name}-${var.env_name}-ecs-logs"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}
