##########################################################
# Cognito User Pool
##########################################################

# Local variable for callback/logout URLs with proper domain prefix
locals {
  cdn_domain = var.domain_prefix != "" ? "cdn.${var.domain_prefix}.${var.domain_name}" : "cdn.${var.domain_name}"
}

module "cognito" {
  source  = "lgallard/cognito-user-pool/aws"
  version = "4.0.0"

  user_pool_name      = "${var.project_name}-userpool-${var.env_name}"
  deletion_protection = false

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
    password_history_size            = 0
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
        "http://localhost:3000/callback"
      ]

      logout_urls = [
        "https://${local.cdn_domain}",
        "http://localhost:3000"
      ]

      allowed_oauth_flows                  = ["code"]
      allowed_oauth_scopes                 = ["openid","email","profile"]
      allowed_oauth_flows_user_pool_client = true
      supported_identity_providers         = ["COGNITO"]
      enable_token_revocation              = true
      prevent_user_existence_errors        = "ENABLED"
      read_attributes                      = ["email","email_verified","preferred_username"]
      write_attributes                     = ["email","preferred_username"]
    }
  ]

  ##########################################################
  # NE DODAJEMO custom domain ili certificate ARN
  ##########################################################

  tags = {
    Name        = "${var.project_name}-userpool-${var.env_name}"
    Project     = "Delux"
    Environment = var.env_name
  }
}
