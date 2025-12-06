output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = module.my_bucket.this_bucket_name
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.my_bucket.this_bucket_arn
}

output "bucket_id" {
  description = "The ID of the S3 bucket"
  value       = module.my_bucket.this_bucket_id
}
