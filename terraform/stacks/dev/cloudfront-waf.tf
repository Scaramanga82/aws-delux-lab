# ##########################################################
# # WAF Web ACL for CloudFront
# ##########################################################

# resource "aws_wafv2_web_acl" "cloudfront" {
#   provider = aws.us_east_1  # WAF za CloudFront MORA biti u us-east-1

#   name  = "${var.project_name}-${var.env_name}-cloudfront-waf"
#   scope = "CLOUDFRONT"

#   default_action {
#     allow {}
#   }

#   # Rule 1: Rate limiting (prevent DDoS)
#   rule {
#     name     = "rate-limit-per-ip"
#     priority = 1

#     action {
#       block {
#         custom_response {
#           response_code = 429
#         }
#       }
#     }

#     statement {
#       rate_based_statement {
#         limit              = var.waf_rate_limit
#         aggregate_key_type = "IP"
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "${var.project_name}-${var.env_name}-rate-limit"
#       sampled_requests_enabled   = true
#     }
#   }

#   # Rule 2: AWS Managed Rules - Core Rule Set
#   rule {
#     name     = "aws-managed-core-rule-set"
#     priority = 10

#     override_action {
#       none {}
#     }

#     statement {
#       managed_rule_group_statement {
#         vendor_name = "AWS"
#         name        = "AWSManagedRulesCommonRuleSet"

#         # Exclude rules that might be too strict
#         rule_action_override {
#           name = "SizeRestrictions_BODY"
#           action_to_use {
#             count {}
#           }
#         }
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "${var.project_name}-${var.env_name}-core-rules"
#       sampled_requests_enabled   = true
#     }
#   }

#   # Rule 3: AWS Managed Rules - Known Bad Inputs
#   rule {
#     name     = "aws-managed-known-bad-inputs"
#     priority = 20

#     override_action {
#       none {}
#     }

#     statement {
#       managed_rule_group_statement {
#         vendor_name = "AWS"
#         name        = "AWSManagedRulesKnownBadInputsRuleSet"
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "${var.project_name}-${var.env_name}-bad-inputs"
#       sampled_requests_enabled   = true
#     }
#   }

#   # Rule 4: Geo blocking (optional)
#   dynamic "rule" {
#     for_each = length(var.waf_blocked_countries) > 0 ? [1] : []

#     content {
#       name     = "geo-blocking"
#       priority = 30

#       action {
#         block {}
#       }

#       statement {
#         geo_match_statement {
#           country_codes = var.waf_blocked_countries
#         }
#       }

#       visibility_config {
#         cloudwatch_metrics_enabled = true
#         metric_name                = "${var.project_name}-${var.env_name}-geo-block"
#         sampled_requests_enabled   = true
#       }
#     }
#   }

#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     metric_name                = "${var.project_name}-${var.env_name}-waf"
#     sampled_requests_enabled   = true
#   }

#   tags = {
#     Name        = "${var.project_name}-${var.env_name}-cloudfront-waf"
#     Project     = var.project_name
#     Environment = var.env_name
#     ManagedBy   = "Terraform"
#   }
# }

# ##########################################################
# # CloudWatch Log Group for WAF Logs
# ##########################################################

# resource "aws_cloudwatch_log_group" "waf" {
#   provider = aws.us_east_1

#   name              = "/aws/wafv2/${var.project_name}-${var.env_name}-cloudfront"
#   retention_in_days = var.waf_log_retention_days

#   tags = {
#     Name        = "${var.project_name}-${var.env_name}-waf-logs"
#     Project     = var.project_name
#     Environment = var.env_name
#     ManagedBy   = "Terraform"
#   }
# }

# ##########################################################
# # WAF Logging Configuration
# ##########################################################

# resource "aws_wafv2_web_acl_logging_configuration" "cloudfront" {
#   provider = aws.us_east_1

#   resource_arn            = aws_wafv2_web_acl.cloudfront.arn
#   log_destination_configs = [aws_cloudwatch_log_group.waf.arn]

#   redacted_fields {
#     single_header {
#       name = "authorization"
#     }
#   }

#   redacted_fields {
#     single_header {
#       name = "cookie"
#     }
#   }
# }
