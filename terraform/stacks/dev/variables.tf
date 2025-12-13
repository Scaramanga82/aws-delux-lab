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

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}