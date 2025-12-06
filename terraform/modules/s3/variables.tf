variable "env" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "versioning" {
  type    = bool
  default = true
}

variable "sse" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}
