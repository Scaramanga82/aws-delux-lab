variable "env_name" {
  description = "Environment name"
  type        = string
}

variable "owner" {
  description = "Owner name"
  type        = string
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "deploy_s3" {
  type    = bool
  default = true
}
