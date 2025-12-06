resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = merge(
    var.tags,
    {
      Environment = var.env
      ManagedBy   = "Terraform"
    }
  )
}

# Versioning (optional)
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  count = var.versioning ? 1 : 0

  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption (optional)
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  count = var.sse ? 1 : 0

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Public access block (optional)
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  count = var.public_access_block ? 1 : 0

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
