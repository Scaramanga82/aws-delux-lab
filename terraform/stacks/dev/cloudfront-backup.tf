# ##########################################################
# # Data Source - Existing ACM Certificate
# ##########################################################

# data "aws_acm_certificate" "cloudfront" {
#   provider = aws.us_east_1

#   domain      = "dev.deluxblock.com"
#   statuses    = ["ISSUED"]
#   most_recent = true
# }

# ##########################################################
# # CloudFront Distribution
# ##########################################################

# module "cloudfront" {
#   source  = "terraform-aws-modules/cloudfront/aws"
#   version = "6.0.2"

#   aliases = [var.frontend_domain]

#   comment             = "${var.project_name} ${var.env_name} CDN"
#   enabled             = true
#   is_ipv6_enabled     = true
#   price_class         = var.cloudfront_price_class
#   http_version        = "http2and3"
#   wait_for_deployment = false
#   web_acl_id          = aws_wafv2_web_acl.cloudfront.arn

#   # S3 Origin
#   origin = {
#     s3_frontend = {
#       domain_name              = module.s3_frontend.s3_bucket_bucket_regional_domain_name
#       origin_access_control_id = "E305S388YGR6FD"
#       origin_id                = "s3_frontend"
#     }
#   }

#   # Origin Access Control (OAC) - Newer than OAI
#   origin_access_control = {
#     s3_oac = {
#       description      = "OAC for ${var.project_name} ${var.env_name} frontend"
#       origin_type      = "s3"
#       signing_behavior = "always"
#       signing_protocol = "sigv4"
#     }
#   }

#   # Default cache behavior
#   default_cache_behavior = {
#     target_origin_id       = "s3_frontend"
#     viewer_protocol_policy = "redirect-to-https"

#     # Managed policies
#     cache_policy_id          = data.aws_cloudfront_cache_policy.caching_optimized.id
#     origin_request_policy_id = data.aws_cloudfront_origin_request_policy.cors_s3.id
#     response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id
#   }

#   # Ordered cache behaviors for SPA routing
#   ordered_cache_behavior = [
#     {
#       path_pattern           = "/static/*"
#       target_origin_id       = "s3_frontend"
#       viewer_protocol_policy = "redirect-to-https"

#       # Managed policies
#       cache_policy_id          = data.aws_cloudfront_cache_policy.caching_optimized.id
#       origin_request_policy_id = data.aws_cloudfront_origin_request_policy.cors_s3.id
#     }
#   ]

#   # Custom error responses for SPA routing
#   custom_error_response = [
#     {
#       error_code         = 403
#       response_code      = 200
#       response_page_path = "/index.html"
#     },
#     {
#       error_code         = 404
#       response_code      = 200
#       response_page_path = "/index.html"
#     }
#   ]

#   # SSL/TLS Certificate
#   viewer_certificate = {
#     acm_certificate_arn      = data.aws_acm_certificate.cloudfront.arn
#     ssl_support_method       = "sni-only"
#     minimum_protocol_version = "TLSv1.2_2021"
#   }

#   restrictions = {
#     geo_restriction = {
#       restriction_type = var.cloudfront_geo_restriction_type
#       locations        = var.cloudfront_geo_restriction_locations
#     }
#   }

#   tags = {
#     Name        = "${var.project_name}-${var.env_name}-cloudfront"
#     Project     = var.project_name
#     Environment = var.env_name
#     ManagedBy   = "Terraform"
#   }
# }

# ##########################################################
# # CloudFront Response Headers Policy (Security)
# ##########################################################

# resource "aws_cloudfront_response_headers_policy" "security_headers" {
#   name    = "${var.project_name}-${var.env_name}-security-headers"
#   comment = "Security headers for ${var.project_name} ${var.env_name}"

#   security_headers_config {
#     strict_transport_security {
#       access_control_max_age_sec = 31536000
#       include_subdomains         = true
#       preload                    = true
#       override                   = true
#     }

#     content_type_options {
#       override = true
#     }

#     frame_options {
#       frame_option = "DENY"
#       override     = true
#     }

#     xss_protection {
#       mode_block = true
#       protection = true
#       override   = true
#     }

#     referrer_policy {
#       referrer_policy = "strict-origin-when-cross-origin"
#       override        = true
#     }
#   }

#   cors_config {
#     access_control_allow_origins {
#       items = ["https://${var.frontend_domain}"]
#     }

#     access_control_allow_headers {
#       items = ["*"]
#     }

#     access_control_allow_methods {
#       items = ["GET", "HEAD", "OPTIONS"]
#     }

#     access_control_allow_credentials = false
#     origin_override                  = true
#   }
# }

# ##########################################################
# # Data Sources
# ##########################################################

# # AWS managed cache policy
# data "aws_cloudfront_cache_policy" "caching_optimized" {
#   name = "Managed-CachingOptimized"
# }

# # AWS managed origin request policy
# data "aws_cloudfront_origin_request_policy" "cors_s3" {
#   name = "Managed-CORS-S3Origin"
# }
