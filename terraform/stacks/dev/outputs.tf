# Ime S3 bucketa
output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = module.my_bucket.bucket
}

# ARN S3 bucketa
output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.my_bucket.arn
}

# ID S3 bucketa
output "bucket_id" {
  description = "The ID of the S3 bucket"
  value       = module.my_bucket.id
}
