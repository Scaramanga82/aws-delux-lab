##########################################################
# Cognito User Pool
##########################################################

# Local variable for callback/logout URLs with proper domain prefix
locals {
  cdn_domain = var.domain_prefix != "" ? "cdn.${var.domain_prefix}.${var.domain_name}" : "cdn.${var.domain_name}"
}

module "cognito" {
  source  = "lgallard/cognito-user-pool/aws"
  version = "~> 0.24"

  user_pool_name = "${var.project_name}-userpool-${var.env_name}"

  ##########################################################
  # Alias and verification attributes
  ##########################################################

  alias_attributes         = ["email", "preferred_username"]
  auto_verified_attributes = ["email"]

  ##########################################################
  # Password policy
  ##########################################################

  password_policy = {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  ##########################################################
  # Email configuration
  ##########################################################

  email_configuration = {
    email_sending_account = "COGNITO_DEFAULT"
  }

  ##########################################################
  # MFA configuration
  ##########################################################

  mfa_configuration = var.cognito_mfa_configuration
  
  software_token_mfa_configuration = {
    enabled = true
  }

  ##########################################################
  # Account recovery
  ##########################################################

  account_recovery_setting = {
    recovery_mechanisms = [
      {
        name     = "verified_email"
        priority = 1
      }
    ]
  }

  ##########################################################
  # User pool add-ons (Advanced Security)
  ##########################################################

  user_pool_add_ons = {
    advanced_security_mode = "ENFORCED"
  }

  ##########################################################
  # App clients
  ##########################################################

  clients = [
    {
      name                          = "${var.project_name}-app-client-${var.env_name}"
      generate_secret               = false
      refresh_token_validity        = var.cognito_refresh_token_validity_days
      access_token_validity         = var.cognito_access_token_validity_minutes
      id_token_validity             = var.cognito_id_token_validity_minutes
      
      token_validity_units = {
        access_token  = "minutes"
        id_token      = "minutes"
        refresh_token = "days"
      }
      
      explicit_auth_flows = [
        "ALLOW_REFRESH_TOKEN_AUTH",
        "ALLOW_USER_SRP_AUTH"
      ]
      
      callback_urls = [
        "https://${local.cdn_domain}/callback.html",
        "https://${local.cdn_domain}/callback/index.html",
        "http://localhost:3000/callback",
        "http://localhost:3001/callback"
      ]
      
      logout_urls = [
        "https://${local.cdn_domain}",
        "http://localhost:3000",
        "http://localhost:3001"
      ]
      
      allowed_oauth_flows                  = ["code"]
      allowed_oauth_scopes                 = ["openid", "email", "profile"]
      allowed_oauth_flows_user_pool_client = true
      supported_identity_providers         = ["COGNITO"]
      
      enable_token_revocation           = true
      prevent_user_existence_errors     = "ENABLED"
      
      read_attributes  = ["email", "email_verified", "preferred_username"]
      write_attributes = ["email", "preferred_username"]
    }
  ]

  ##########################################################
  # Custom domain configuration
  ##########################################################

  # For dev/stage: "auth.dev" -> results in "auth.dev.kanazir.link"
  # For prod: "auth" -> results in "auth.kanazir.link"
  domain                 = var.domain_prefix != "" ? "auth.${var.domain_prefix}" : "auth"
  domain_certificate_arn = aws_acm_certificate.cloudfront.arn

  ##########################################################
  # Tags
  ##########################################################

  tags = {
    Name        = "${var.project_name}-userpool-${var.env_name}"
    Project     = "Delux"
    Environment = var.env_name
  }
}