output "bucket_id" {
  value = length(aws_s3_bucket.this) > 0 ? aws_s3_bucket.this[0].id : ""
}

output "bucket_arn" {
  value = length(aws_s3_bucket.this) > 0 ? aws_s3_bucket.this[0].arn : ""
}
