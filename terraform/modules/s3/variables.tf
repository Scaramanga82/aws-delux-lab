variable "env_name" {
  type        = string
  description = "Environment name, e.g., dev/stage/prod"
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags for the bucket"
}

variable "create_bucket" {
  type        = bool
  default     = true
  description = "Whether to create the bucket or not"
}

variable "versioning" {
  type        = bool
  default     = false
  description = "Enable versioning for the bucket"
}

variable "sse" {
  type        = bool
  default     = false
  description = "Enable server-side encryption for the bucket"
}

variable "public_access_block" {
  type        = bool
  description = "Whether to enable public access block on the bucket"
  default     = false
}
