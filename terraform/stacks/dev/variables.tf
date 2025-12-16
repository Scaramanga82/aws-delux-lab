##########################################################
# General variables
##########################################################

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "env_name" {
  description = "Environment name (dev/stage/prod)"
  type        = string
}

variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "delux"
}

variable "domain_name" {
  description = "Root domain name (e.g., kanazir.link)"
  type        = string
}

variable "domain_prefix" {
  description = "Domain prefix for environment (dev/stage/prod uses empty string)"
  type        = string
  default     = ""
}

##########################################################
# Cognito variables
##########################################################

variable "cognito_user_pool_tier" {
  description = "Cognito User Pool tier (ESSENTIALS or PLUS)"
  type        = string
  default     = "ESSENTIALS"

  validation {
    condition     = contains(["ESSENTIALS", "PLUS"], var.cognito_user_pool_tier)
    error_message = "Tier must be ESSENTIALS or PLUS."
  }
}

variable "cognito_advanced_security_mode" {
  description = "Advanced security mode (OFF, AUDIT, ENFORCED). ENFORCED requires PLUS tier."
  type        = string
  default     = "AUDIT"

  validation {
    condition     = contains(["OFF", "AUDIT", "ENFORCED"], var.cognito_advanced_security_mode)
    error_message = "Security mode must be OFF, AUDIT, or ENFORCED."
  }
}

variable "cognito_mfa_configuration" {
  description = "MFA configuration (OFF, ON, OPTIONAL)"
  type        = string
  default     = "OPTIONAL"
}

variable "cognito_refresh_token_validity_days" {
  description = "Refresh token validity in days"
  type        = number
  default     = 5
}

variable "cognito_access_token_validity_minutes" {
  description = "Access token validity in minutes"
  type        = number
  default     = 60
}

variable "cognito_id_token_validity_minutes" {
  description = "ID token validity in minutes"
  type        = number
  default     = 60
}


##########################################################
# VPC Variables
##########################################################
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway for all AZs"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}

##########################################################
# Aurora PostgreSQL Variables
##########################################################

variable "aurora_postgresql_engine_version" {
  description = "Aurora PostgreSQL engine version"
  type        = string
  default     = "17.4"
}

variable "aurora_postgresql_instance_class" {
  description = "Aurora PostgreSQL instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "aurora_postgresql_backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 1
}

variable "aurora_postgresql_backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "aurora_postgresql_maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

##########################################################
# ECS Variables
##########################################################

variable "ecs_container_port" {
  description = "Port on which the container listens"
  type        = number
  default     = 80
}

variable "ecs_health_check_path" {
  description = "Health check path for the application"
  type        = string
  default     = "/"
}

variable "ecs_cpu" {
  description = "CPU units for ECS task"
  type        = number
  default     = 256
}

variable "ecs_memory" {
  description = "Memory (MB) for ECS task"
  type        = number
  default     = 512
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

variable "ecs_image" {
  description = "Docker image for ECS task"
  type        = string
  default     = "nginx:latest"
}

##########################################################
# Frontend (CloudFront + S3) Variables
##########################################################

variable "frontend_domain" {
  description = "Frontend domain name"
  type        = string
}

variable "cloudfront_price_class" {
  description = "CloudFront price class (PriceClass_100, PriceClass_200, PriceClass_All)"
  type        = string
  default     = "PriceClass_100"  # US, Canada, Europe
}

variable "cloudfront_geo_restriction_type" {
  description = "Geo restriction type (none, whitelist, blacklist)"
  type        = string
  default     = "none"
}

variable "cloudfront_geo_restriction_locations" {
  description = "List of country codes for geo restrictions (ISO 3166-1 alpha-2)"
  type        = list(string)
  default     = []
}

variable "cloudfront_log_retention_days" {
  description = "CloudFront logs retention in days"
  type        = number
  default     = 90
}

##########################################################
# WAF Variables
##########################################################

variable "waf_rate_limit" {
  description = "WAF rate limit per IP (requests per 5 minutes)"
  type        = number
  default     = 2000
}

variable "waf_blocked_countries" {
  description = "List of country codes to block (ISO 3166-1 alpha-2)"
  type        = list(string)
  default     = []
  # Example: ["CN", "RU", "KP"]
}

variable "waf_log_retention_days" {
  description = "WAF logs retention in days"
  type        = number
  default     = 90
}
