##########################################################
# AWS Providers
##########################################################

# Primary provider (eu-west-2 London)
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.env_name
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# Provider for us-east-1 (required for ACM certificate for CloudFront)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = var.env_name
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

##########################################################
# ACM Certificate (us-east-1 - CloudFront requirement)
##########################################################

resource "aws_acm_certificate" "cloudfront" {
  provider = aws.us_east_1

  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.domain_name}"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-cert-${var.env_name}"
  }
}