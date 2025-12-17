##########################################################
# Cognito User Pool
##########################################################

module "cognito" {
  source  = "lgallard/cognito-user-pool/aws"
  version = "4.0.0"

  user_pool_name      = "${var.project_name}-userpool-${var.env_name}"
  deletion_protection = "INACTIVE"
  user_pool_tier      = var.cognito_user_pool_tier

  ##########################################################
  # Admin create user config
  ##########################################################
  admin_create_user_config = {
    allow_admin_create_user_only = false
  }

  ##########################################################
  # Primari login identity
  ##########################################################
  username_attributes = ["email"]

  ##########################################################
  # Alias and verification attributes
  ##########################################################

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
    advanced_security_mode = var.cognito_advanced_security_mode
  }

  ##########################################################
  # App clients
  ##########################################################

  clients = [
    {
      name                   = "${var.project_name}-app-client-${var.env_name}"
      generate_secret        = false
      refresh_token_validity = var.cognito_refresh_token_validity_days
      access_token_validity  = var.cognito_access_token_validity_minutes
      id_token_validity      = var.cognito_id_token_validity_minutes

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
        "https://cdn.dev.kanazir.link/callback.html",
        "http://localhost:3000/callback"
      ]

      logout_urls = [
        "https://cdn.dev.kanazir.link",
        "http://localhost:3000"
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

  tags = {
    Name        = "${var.project_name}-userpool-${var.env_name}"
    Project     = "Delux"
    Environment = var.env_name
  }
}

##########################################################
# Cognito Custom Domain
##########################################################

resource "aws_cognito_user_pool_domain" "custom" {
  domain          = "auth.dev.kanazir.link"
  certificate_arn = "arn:aws:acm:us-east-1:220027435491:certificate/38cd5bcd-5dd1-4aa5-a3f1-d09d2381f871"
  user_pool_id    = module.cognito.id

  depends_on = [module.cognito]
}

##########################################################
# Route53 Record za Custom Domain
##########################################################

data "aws_route53_zone" "main" {
  name         = "${var.domain_name}."
  private_zone = false
}

resource "aws_route53_record" "auth" {
  name    = "auth.dev.kanazir.link"
  type    = "A"
  zone_id = data.aws_route53_zone.main.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_cognito_user_pool_domain.custom.cloudfront_distribution
    zone_id                = "Z2FDTNDATAQYW2" # Fixed CloudFront zone ID
  }

  depends_on = [aws_cognito_user_pool_domain.custom]
}