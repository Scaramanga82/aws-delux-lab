# ##########################################################
# # S3 Test bucket Outputs
# ##########################################################
# output "s3_bucket_id" {
#   description = "The name of the bucket"
#   value       = module.s3_bucket.s3_bucket_id
# }

# output "s3_bucket_arn" {
#   description = "The ARN of the bucket"
#   value       = module.s3_bucket.s3_bucket_arn
# }

# output "s3_bucket_region" {
#   description = "The AWS region this bucket resides in"
#   value       = module.s3_bucket.s3_bucket_region
# }

# output "s3_bucket_domain_name" {
#   description = "The bucket domain name"
#   value       = module.s3_bucket.s3_bucket_bucket_domain_name
# }

##########################################################
# ACM Certificate Outputs
##########################################################

output "acm_certificate_arn" {
  description = "ACM certificate ARN (us-east-1)"
  value       = aws_acm_certificate.cloudfront.arn
}

output "acm_certificate_status" {
  description = "ACM certificate validation status"
  value       = aws_acm_certificate.cloudfront.status
}

output "acm_certificate_domain_validation_options" {
  description = "ACM certificate domain validation options (for manual DNS record creation)"
  value       = aws_acm_certificate.cloudfront.domain_validation_options
  sensitive   = false
}

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

output "cognito_domain" {
  description = "Cognito custom domain URL"
  value       = "https://auth.${var.domain_name}"
}

output "cognito_domain_cloudfront" {
  description = "Cognito CloudFront distribution domain (for DNS CNAME record)"
  value       = module.cognito.domain_cloudfront_distribution
}

##########################################################
# Application URLs
##########################################################

output "auth_url" {
  description = "Authentication URL (Cognito Hosted UI)"
  value       = "https://auth.${var.domain_name}"
}

output "login_url" {
  description = "Complete login URL with parameters"
  value       = "https://auth.${var.domain_name}/login?client_id=${module.cognito.client_ids[0]}&response_type=code&scope=openid+email&redirect_uri=https://cdn.${var.domain_name}/callback/index.html"
  sensitive   = true
}

output "logout_url" {
  description = "Complete logout URL with parameters"
  value       = "https://auth.${var.domain_name}/logout?client_id=${module.cognito.client_ids[0]}&logout_uri=https://cdn.${var.domain_name}"
  sensitive   = true
}

##########################################################
# Developer Configuration
##########################################################

output "developer_config" {
  description = "Configuration for developers (.env file)"
  value = {
    REACT_APP_COGNITO_REGION    = var.aws_region
    REACT_APP_COGNITO_CLIENT_ID = module.cognito.client_ids[0]
    REACT_APP_COGNITO_DOMAIN    = "https://auth.${var.domain_name}"
    REACT_APP_REDIRECT_URI      = "https://cdn.${var.domain_name}/callback/index.html"
    REACT_APP_LOGOUT_URI        = "https://cdn.${var.domain_name}"
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
    create_test_user      = "aws cognito-idp admin-create-user --user-pool-id ${module.cognito.id} --username testuser --user-attributes Name=email,Value=test@example.com Name=email_verified,Value=true --temporary-password 'TempPass123!' --region ${var.aws_region}"
  }
}

##########################################################
# DNS Configuration Info
##########################################################

output "dns_records_required" {
  description = "DNS records to create manually in Route53"
  value = {
    acm_validation = {
      note   = "Check acm_certificate_domain_validation_options output for CNAME records"
      action = "Create CNAME record(s) in Route53 for ACM certificate validation"
    }
    cognito_auth = {
      name   = "auth.${var.domain_name}"
      type   = "CNAME"
      target = module.cognito.domain_cloudfront_distribution
      ttl    = 300
      note   = "Point to Cognito CloudFront distribution"
    }
  }
}