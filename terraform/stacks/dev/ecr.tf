# ##########################################################
# # ECR Repository
# ##########################################################

# resource "aws_ecr_repository" "app" {
#   name                 = "kanazir-ecr"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }

#   encryption_configuration {
#     encryption_type = "AES256"
#   }

#   tags = {
#     Name        = "${var.project_name}-${var.env_name}-ecr"
#     Project     = var.project_name
#     Environment = var.env_name
#     ManagedBy   = "Terraform"
#   }
# }

# # Lifecycle policy - keep last 10 images
# resource "aws_ecr_lifecycle_policy" "app" {
#   repository = aws_ecr_repository.app.name

#   policy = jsonencode({
#     rules = [
#       {
#         rulePriority = 1
#         description  = "Keep last 10 images"
#         selection = {
#           tagStatus     = "any"
#           countType     = "imageCountMoreThan"
#           countNumber   = 10
#         }
#         action = {
#           type = "expire"
#         }
#       }
#     ]
#   })
# }

# # Output - ecr repository url
# output "ecr_repository_url" {
#   description = "URL of the ECR repository"
#   value       = aws_ecr_repository.app.repository_url
# }

# # Output - ecr repository arn
# output "ecr_repository_arn" {
#   description = "ARN of the ECR repository"
#   value       = aws_ecr_repository.app.arn
# }