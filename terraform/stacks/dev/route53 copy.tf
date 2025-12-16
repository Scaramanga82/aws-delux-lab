# ##########################################################
# # Route53 Records for Frontend (CloudFront)
# ##########################################################

# # dev.deluxblock.com → CloudFront (REPLACE postojeći 192.0.2.1)
# resource "aws_route53_record" "frontend" {
#   zone_id = data.aws_route53_zone.main.zone_id
#   name    = var.frontend_domain
#   type    = "A"

#   alias {
#     name                   = module.cloudfront.cloudfront_distribution_domain_name
#     zone_id                = module.cloudfront.cloudfront_distribution_hosted_zone_id
#     evaluate_target_health = false
#   }
# }

# # IPv6 support (AAAA record)
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
