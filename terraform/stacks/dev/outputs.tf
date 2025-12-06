output "bucket_id" {
  value       = module.my_bucket.id
  description = "ID of the S3 bucket"
}

output "bucket_arn" {
  value       = module.my_bucket.arn
  description = "ARN of the S3 bucket"
}
