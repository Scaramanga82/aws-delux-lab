##########################################################
# General variables
##########################################################

variable "aws_region" {
  description = "AWS Region where primary resources (Cognito) will be deployed, e.g., eu-west-2"
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
  description = "Optional subdomain prefix for environment (dev/stage). Empty string for prod."
  type        = string
  default     = ""
}

##########################################################
# Cognito variables
##########################################################

variable "cognito_mfa_configuration" {
  description = "MFA configuration for Cognito User Pool (OFF, ON, OPTIONAL)"
  type        = string
  default     = "OPTIONAL"
}

variable "cognito_refresh_token_validity_days" {
  description = "Refresh token validity in days for Cognito App Client"
  type        = number
  default     = 5
}

variable "cognito_access_token_validity_minutes" {
  description = "Access token validity in minutes for Cognito App Client"
  type        = number
  default     = 60
}

variable "cognito_id_token_validity_minutes" {
  description = "ID token validity in minutes for Cognito App Client"
  type        = number
  default     = 60
}
