variable "env" {
  description = "Environment name (dev, stage, prod)"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "versioning" {
  description = "Enable versioning on the bucket"
  type        = bool
  default     = false
}

variable "sse" {
  description = "Enable server-side encryption (AES256)"
  type        = bool
  default     = false
}

variable "public_access_block" {
  description = "Enable public access block"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for the bucket"
  type        = map(string)
  default     = {}
}
