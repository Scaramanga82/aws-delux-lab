module "my_bucket" {
  count       = var.deploy_s3 ? 1 : 0
  source      = "../../modules/s3_bucket"
  env         = var.env
  bucket_name = "my-project-dev-bucket"
  versioning  = false
  sse         = true
  tags = {
    Project = "MyProject"
  }
}
