# ##########################################################
# # Application Load Balancer
# ##########################################################

# # ACM Certificate Data Source
# data "aws_acm_certificate" "dev" {
#   domain   = "dev.deluxblock.com"
#   statuses = ["ISSUED"]
# }

# # # Get Route53 Hosted Zone
# # data "aws_route53_zone" "main" {
# #   name         = "deluxblock.com"
# #   private_zone = false
# # }

# ##########################################################
# # Application Load Balancer + Target Groups
# ##########################################################

# module "alb" {
#   source  = "terraform-aws-modules/alb/aws"
#   version = "10.4.0"

#   name    = "${var.project_name}-${var.env_name}-alb"
#   vpc_id  = module.vpc.vpc_id
#   subnets = module.vpc.public_subnets
#   enable_deletion_protection = false

#   # Security Group
#   create_security_group = false
#   security_groups       = [aws_security_group.alb.id]

#   # Listeners
#   listeners = {
#     http = {
#       port     = 80
#       protocol = "HTTP"

#       redirect = {
#         port        = "443"
#         protocol    = "HTTPS"
#         status_code = "HTTP_301"
#       }
#     }

#     https = {
#       port            = 443
#       protocol        = "HTTPS"
#       certificate_arn = data.aws_acm_certificate.dev.arn
#       ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"

#       fixed_response = {
#         content_type = "application/json"
#         message_body = jsonencode({
#           error   = "Direct access forbidden"
#           message = "Please use the official domain"
#         })
#         status_code = "403"
#       }

#       rules = {
#         # Rule 1: Health check (without header validation)
#         health_check = {
#           priority = 1

#           actions = [{
#             type             = "forward"
#             target_group_key = "ecs"
#           }]

#           conditions = [{
#             path_pattern = {
#               values = ["/health", "/healthz"]
#             }
#           }]
#         }

#         # Rule 2: CloudFront header validation
#         allow_cloudfront = {
#           priority = 10

#           actions = [{
#             type             = "forward"
#             target_group_key = "ecs"
#           }]

#           conditions = [{
#             http_header = {
#               http_header_name = "X-CloudFront-Secret"
#               values           = [data.aws_secretsmanager_secret_version.cloudfront_secret.secret_string]
#             }
#           }]
#         }
#       }
#     }
#   }

#   target_groups = {
#     ecs = {
#       name = "${var.project_name}-${var.env_name}-tg-ecs"
#       backend_protocol = "HTTP"
#       backend_port     = var.ecs_container_port
#       target_type      = "ip"

#       health_check = {
#         enabled             = true
#         healthy_threshold   = 2
#         unhealthy_threshold = 3
#         timeout             = 5
#         interval            = 30
#         path                = var.ecs_health_check_path
#         protocol            = "HTTP"
#         matcher             = "200"
#       }

#       deregistration_delay = 30

#       create_attachment = false
#     }
#   }

#   tags = {
#     Name        = "${var.project_name}-${var.env_name}-alb"
#     Project     = var.project_name
#     Environment = var.env_name
#     ManagedBy   = "Terraform"
#   }
# }
