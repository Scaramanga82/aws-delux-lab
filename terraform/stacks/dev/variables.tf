variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "env_name" {
  type        = string
  description = "Environment name (dev, stage, prod)"
}

variable "owner" {
  type        = string
  description = "Project owner or identifier"
}

variable "deploy_s3" {
  type        = bool
  description = "Whether to deploy the S3 bucket"
  default     = true
}
