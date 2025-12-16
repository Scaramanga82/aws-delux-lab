##########################################################
# Route53 A Record
##########################################################

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "api.dev.kanazir.link"
  type    = "A"

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}

##########################################################
# Route53 Records for Frontend (CloudFront)
##########################################################

resource "aws_route53_record" "frontend" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.frontend_domain
  type    = "A"

  alias {
    name                   = module.cloudfront.cloudfront_distribution_domain_name
    zone_id                = module.cloudfront.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }
}

# # IPv6 support (AAAA record) - add in production
# resource "aws_route53_record" "frontend_ipv6" {
#   zone_id = data.aws_route53_zone.main.zone_id
#   name    = var.frontend_domain
#   type    = "AAAA"

#   alias {
#     name                   = module.cloudfront.cloudfront_distribution_domain_name
#     zone_id                = module.cloudfront.cloudfront_distribution_hosted_zone_id
#     evaluate_target_health = false
#   }
# }
