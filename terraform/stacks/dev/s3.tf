module "my_bucket" {
  count       = var.deploy_s3 ? 1 : 0
  source      = "../../modules/s3"
  env         = var.env_name
  bucket_name = "${var.env_name}-${var.owner}-bucket"
  versioning  = true
  sse         = true
  public_access_block = true
  tags = {
    Project = "DevOps-Infra"
  }
}
