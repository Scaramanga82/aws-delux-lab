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

# output "cognito_client_id" {
#   description = "Cognito App Client ID"
#   value       = module.cognito.client_ids[0]
#   sensitive   = true
# }

# output "auth_url" {
#   description = "Cognito Hosted UI URL (manual domain configuration)"
#   value       = "https://${var.domain_prefix != "" ? "auth.${var.domain_prefix}.${var.domain_name}" : "auth.${var.domain_name}"}"
# }
