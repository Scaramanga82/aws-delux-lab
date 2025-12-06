module "my_bucket" {
  source        = "git::https://github.com/babenkov/terraform-aws-s3.git?ref=vX.Y.Z"

  name          = "${var.env_name}-${var.owner}-bucket"
  create_bucket = var.deploy_s3

  versioning    = false       # možeš uključiti po potrebi
  sse           = true        # server-side encryption
  tags = {
    Environment = var.env_name
  }
}
