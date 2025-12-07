##########################################################
# AWS Providers
##########################################################

# Primary provider (eu-west-2 London)
provider "aws" {
  # alias  = "default"
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
