# Get Route53 Hosted Zone
data "aws_route53_zone" "main" {
  name         = "kanazir.link"
  private_zone = false
}
