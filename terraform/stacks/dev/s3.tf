# ##########################################################
# # S3 Test bucket
# ##########################################################
# module "s3_bucket" {
#   source  = "terraform-aws-modules/s3-bucket/aws"
#   version = "5.9.0"

#   bucket = "${var.env_name}-milos-projekat-bucket"

#   control_object_ownership = true
#   object_ownership         = "BucketOwnerEnforced"

#   versioning = {
#     enabled = false
#   }

#   server_side_encryption_configuration = {
#     rule = {
#       apply_server_side_encryption_by_default = {
#         sse_algorithm = "AES256"
#       }
#       bucket_key_enabled       = true
#     }
#   }

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true

#   tags = {
#     Project     = "Milos-Projekat"
#     Environment = var.env_name
#   }
# }

##########################################################
# S3 Bucket for Frontend Static Files
##########################################################

module "s3_frontend" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.9.0"

  bucket = "${var.project_name}-${var.env_name}-frontend"

  # Block all public access (CloudFront uses OAC)
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Versioning
  versioning = {
    enabled = true
  }

  # Encryption
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = true
    }
  }

  # Lifecycle rules - cleanup old versions
  lifecycle_rule = [
    {
      id      = "cleanup-old-versions"
      enabled = true

      noncurrent_version_expiration = {
        days = 30
      }

      abort_incomplete_multipart_upload = {
        days_after_initiation = 7
      }
    }
  ]

  # CORS for frontend
  cors_rule = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = [
        "https://${var.frontend_domain}"
      ]
      expose_headers  = ["ETag"]
      max_age_seconds = 3600
    }
  ]

  tags = {
    Name        = "${var.project_name}-${var.env_name}-frontend"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}


# S3 Bucket Policy for CloudFront OAC
resource "aws_s3_bucket_policy" "cloudfront_oac" {
  bucket = module.s3_frontend.s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${module.s3_frontend.s3_bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = module.cloudfront.cloudfront_distribution_arn
          }
        }
      }
    ]
  })

  depends_on = [module.cloudfront]
}

##########################################################
# S3 Bucket for CloudFront Logs
##########################################################

module "s3_cloudfront_logs" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.9.0"

  bucket = "${var.project_name}-${var.env_name}-cloudfront-logs"

  # Block public access
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Lifecycle - auto-delete old logs
  lifecycle_rule = [
    {
      id      = "delete-old-logs"
      enabled = true

      expiration = {
        days = var.cloudfront_log_retention_days
      }
    }
  ]

  # Grant CloudFront permission to write logs
  grant = [
    {
      type       = "CanonicalUser"
      permission = "FULL_CONTROL"
      id         = data.aws_cloudfront_log_delivery_canonical_user_id.current.id
    }
  ]

  tags = {
    Name        = "${var.project_name}-${var.env_name}-cloudfront-logs"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}

