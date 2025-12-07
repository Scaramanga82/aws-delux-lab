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

# ##########################################################
# # Cognito User Pool Outputs
# ##########################################################

# output "cognito_user_pool_id" {
#   description = "Cognito User Pool ID"
#   value       = module.cognito.id
# }

# output "cognito_user_pool_arn" {
#   description = "Cognito User Pool ARN"
#   value       = module.cognito.arn
# }

# output "cognito_user_pool_endpoint" {
#   description = "Cognito User Pool endpoint"
#   value       = module.cognito.endpoint
# }

# output "cognito_client_id" {
#   description = "Cognito App Client ID"
#   value       = module.cognito.client_ids[0]
#   sensitive   = true
# }

# ##########################################################
# # Application URLs
# ##########################################################

# output "auth_url" {
#   description = "Cognito Hosted UI URL (manual domain configuration)"
#   value       = "https://${var.domain_prefix != "" ? "auth.${var.domain_prefix}.${var.domain_name}" : "auth.${var.domain_name}"}"
# }

# output "cdn_url" {
#   description = "CDN URL (CloudFront - to be configured)"
#   value       = "https://${var.domain_prefix != "" ? "cdn.${var.domain_prefix}.${var.domain_name}" : "cdn.${var.domain_name}"}"
# }

# ##########################################################
# # Developer Configuration
# ##########################################################

# output "developer_config" {
#   description = "Configuration for developers (.env file)"
#   value = {
#     REACT_APP_COGNITO_REGION    = var.aws_region
#     REACT_APP_COGNITO_CLIENT_ID = module.cognito.client_ids[0]
#     REACT_APP_COGNITO_DOMAIN    = "https://${var.domain_prefix != "" ? "auth.${var.domain_prefix}.${var.domain_name}" : "auth.${var.domain_name}"}"
#     REACT_APP_REDIRECT_URI      = "https://${var.domain_prefix != "" ? "cdn.${var.domain_prefix}.${var.domain_name}" : "cdn.${var.domain_name}"}/callback.html"
#     REACT_APP_LOGOUT_URI        = "https://${var.domain_prefix != "" ? "cdn.${var.domain_prefix}.${var.domain_name}" : "cdn.${var.domain_name}"}"
#   }
#   sensitive = true
# }

# ##########################################################
# # Deployment Commands
# ##########################################################

# output "deployment_commands" {
#   description = "Useful deployment commands"
#   value = {
#     get_cognito_client_id = "terraform output -raw cognito_client_id"
#     create_test_user      = "aws cognito-idp admin-create-user --user-pool-id ${module.cognito.id} --username testuser --user-attributes Name=email,Value=test@example.com Name=email_verified,Value=true --temporary-password 'TempPass123!' --region ${var.aws_region}"
#   }
# }