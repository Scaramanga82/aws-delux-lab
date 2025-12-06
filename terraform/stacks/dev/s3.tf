module "my_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.9.0"

  bucket = "${var.env_name}-milos-projekat-bucket"
  acl    = "private"

  versioning = {
    enabled = false
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Project     = "Milos-Projekat"
    Environment = var.env_name
  }
}
