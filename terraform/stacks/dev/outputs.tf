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

output "cognito_domain_prefix" {
  description = "Cognito domain prefix (for testing)"
  value       = "https://${aws_cognito_user_pool_domain.prefix.domain}.auth.${var.aws_region}.amazoncognito.com"
}

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