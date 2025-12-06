variable "env" {
  default = "dev"
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "deploy_s3" {
  type    = bool
  default = true
}
