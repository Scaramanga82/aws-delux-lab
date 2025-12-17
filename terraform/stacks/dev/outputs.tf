##########################################################
# Cognito User Pool Outputs
##########################################################

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.cognito.id
}

output "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = module.cognito.arn
}

output "cognito_user_pool_endpoint" {
  description = "Cognito User Pool endpoint"
  value       = module.cognito.endpoint
}

output "cognito_client_id" {
  description = "Cognito App Client ID"
  value       = module.cognito.client_ids[0]
  sensitive   = true
}

##########################################################
# Cognito Domain Outputs
##########################################################

output "cognito_domain_custom" {
  description = "Cognito custom domain"
  value       = "https://${aws_cognito_user_pool_domain.custom.domain}"
}

output "cognito_domain_cloudfront" {
  description = "CloudFront distribution for custom domain"
  value       = aws_cognito_user_pool_domain.custom.cloudfront_distribution
}

##########################################################
# Application URLs
##########################################################

output "auth_url" {
  description = "Cognito Hosted UI URL"
  value       = "https://${local.auth_domain}"
}

output "cdn_url" {
  description = "CDN URL (CloudFront - to be configured)"
  value       = "https://${local.cdn_domain}"
}

##########################################################
# Developer Configuration
##########################################################

output "developer_config" {
  description = "Configuration for developers (.env file)"
  value = {
    REACT_APP_COGNITO_REGION      = var.aws_region
    REACT_APP_COGNITO_USER_POOL_ID = module.cognito.id
    REACT_APP_COGNITO_CLIENT_ID   = module.cognito.client_ids[0]
    REACT_APP_COGNITO_DOMAIN      = "https://${local.auth_domain}"
    REACT_APP_REDIRECT_URI        = "https://${local.cdn_domain}/callback.html"
    REACT_APP_LOGOUT_URI          = "https://${local.cdn_domain}"
  }
  sensitive = true
}

##########################################################
# Deployment Commands
##########################################################

output "deployment_commands" {
  description = "Useful deployment commands"
  value = {
    get_cognito_client_id = "terraform output -raw cognito_client_id"
    test_prefix_domain    = "terraform output -raw cognito_domain_prefix"
    test_custom_domain    = "terraform output -raw cognito_domain_custom"
    create_test_user      = "aws cognito-idp admin-create-user --user-pool-id ${module.cognito.id} --username testuser --user-attributes Name=email,Value=test@example.com Name=email_verified,Value=true --temporary-password 'TempPass123!' --region ${var.aws_region}"
  }
}

##########################################################
# Test Login URLs
##########################################################

output "test_login_urls" {
  description = "Test login URLs for both domains"
  value = {
    prefix_domain = "${aws_cognito_user_pool_domain.prefix.domain}.auth.${var.aws_region}.amazoncognito.com/login?client_id=${module.cognito.client_ids[0]}&response_type=code&scope=email+openid+profile&redirect_uri=http://localhost:3000/callback"
    custom_domain = "${local.auth_domain}/login?client_id=${module.cognito.client_ids[0]}&response_type=code&scope=email+openid+profile&redirect_uri=http://localhost:3000/callback"
  }
  sensitive = true
}

##########################################################
# VPC Outputs
##########################################################

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

output "azs" {
  description = "A list of availability zones"
  value       = module.vpc.azs
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks of private subnets"
  value       = var.private_subnets
}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks of public subnets"
  value       = var.public_subnets
}

##########################################################
# Aurora PostgreSQL Outputs
##########################################################

output "aurora_cluster_endpoint" {
  description = "Aurora cluster writer endpoint"
  value       = module.aurora_postgresql_cluster.cluster_endpoint
}

output "aurora_cluster_reader_endpoint" {
  description = "Aurora cluster reader endpoint"
  value       = module.aurora_postgresql_cluster.cluster_reader_endpoint
}

output "aurora_cluster_port" {
  description = "Aurora cluster port"
  value       = module.aurora_postgresql_cluster.cluster_port
}

output "aurora_cluster_id" {
  description = "Aurora cluster identifier"
  value       = module.aurora_postgresql_cluster.cluster_id
}

output "aurora_cluster_arn" {
  description = "Aurora cluster ARN"
  value       = module.aurora_postgresql_cluster.cluster_arn
}

output "aurora_database_name" {
  description = "Aurora database name"
  value       = local.aurora_dbname
  sensitive   = true
}

output "aurora_master_username" {
  description = "Aurora master username"
  value       = local.aurora_username
  sensitive   = true
}

output "aurora_connection_string" {
  description = "Aurora connection information (for reference)"
  value = {
    database = local.aurora_dbname
    username = local.aurora_username
  }
  sensitive = true
}

##########################################################
# Application Load Balancer Outputs
##########################################################

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = module.alb.zone_id
}

output "alb_arn" {
  description = "ARN of the load balancer"
  value       = module.alb.arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = module.alb.target_groups["ecs"].arn
}

output "api_url" {
  description = "API URL"
  value       = "https://api.dev.kanazir.link"
}

##########################################################
# ECS Cluster Outputs
##########################################################

output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.ecs_cluster.cluster_id
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_cluster.cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs_cluster.cluster_arn
}

##########################################################
# ECS Task Definition Outputs
##########################################################

# output "ecs_service_id" {
#   description = "ID of the ECS service"
#   value       = module.ecs_service.id
# }

# output "ecs_service_name" {
#   description = "Name of the ECS service"
#   value       = module.ecs_service.name
# }

# output "ecs_task_definition_arn" {
#   description = "ARN of the task definition"
#   value       = module.ecs_service.task_definition_arn
# }


# output "ecs_service_name" {
#   value = aws_ecs_service.app.name
# }

# output "ecs_service_id" {
#   value = aws_ecs_service.app.id
# }

# output "ecs_task_definition_arn" {
#   value = aws_ecs_task_definition.app.arn
# }

# output "ecs_log_group_name" {
#   value = aws_cloudwatch_log_group.ecs_app.name
# }

# ##########################################################
# # Frontend Outputs
# ##########################################################

# output "cloudfront_distribution_id" {
#   description = "CloudFront distribution ID"
#   value       = module.cloudfront.cloudfront_distribution_id
# }

# output "cloudfront_distribution_domain" {
#   description = "CloudFront distribution domain name"
#   value       = module.cloudfront.cloudfront_distribution_domain_name
# }

# output "frontend_url" {
#   description = "Frontend URL"
#   value       = "https://${var.frontend_domain}"
# }

# output "s3_frontend_bucket" {
#   description = "S3 frontend bucket name"
#   value       = module.s3_frontend.s3_bucket_id
# }

# output "s3_frontend_bucket_arn" {
#   description = "S3 frontend bucket ARN"
#   value       = module.s3_frontend.s3_bucket_arn
# }

# output "acm_certificate_arn" {
#   description = "ACM certificate ARN for CloudFront"
#   value       = data.aws_acm_certificate.cloudfront.arn
# }

# ##########################################################
# # Cloudfront WAF Outputs
# ##########################################################

# output "waf_web_acl_id" {
#   description = "WAF Web ACL ID"
#   value       = aws_wafv2_web_acl.cloudfront.id
# }

# output "waf_web_acl_arn" {
#   description = "WAF Web ACL ARN"
#   value       = aws_wafv2_web_acl.cloudfront.arn
# }


# ##########################################################
# # ALB WAF Outputs
# ##########################################################

# output "alb_waf_web_acl_id" {
#   description = "ALB WAF Web ACL ID"
#   value       = aws_wafv2_web_acl.alb.id
# }

# output "alb_waf_web_acl_arn" {
#   description = "ALB WAF Web ACL ARN"
#   value       = aws_wafv2_web_acl.alb.arn
# }

# output "alb_waf_capacity" {
#   description = "ALB WAF capacity units used"
#   value       = aws_wafv2_web_acl.alb.capacity
# }
