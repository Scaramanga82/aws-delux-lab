##########################################################
# WAF Web ACL for ALB (Regional)
##########################################################

resource "aws_wafv2_web_acl" "alb" {
  name  = "${var.project_name}-${var.env_name}-alb-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  # Rule 1: Rate limiting per IP
  rule {
    name     = "rate-limit-per-ip"
    priority = 1

    action {
      block {
        custom_response {
          response_code = 429
          custom_response_body_key = "rate_limit_exceeded"
        }
      }
    }

    statement {
      rate_based_statement {
        limit              = var.alb_waf_rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-${var.env_name}-alb-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  # Rule 2: AWS Managed Rules - Core Rule Set
  rule {
    name     = "aws-managed-core-rule-set"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"

        # Exclude rules that might block legitimate API traffic
        rule_action_override {
          name = "SizeRestrictions_BODY"
          action_to_use {
            count {}
          }
        }

        rule_action_override {
          name = "GenericRFI_BODY"
          action_to_use {
            count {}
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-${var.env_name}-alb-core-rules"
      sampled_requests_enabled   = true
    }
  }

  # Rule 3: SQL Injection Protection
  rule {
    name     = "aws-managed-sql-injection"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesSQLiRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-${var.env_name}-alb-sqli"
      sampled_requests_enabled   = true
    }
  }

  # Rule 4: Known Bad Inputs
  rule {
    name     = "aws-managed-known-bad-inputs"
    priority = 30

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-${var.env_name}-alb-bad-inputs"
      sampled_requests_enabled   = true
    }
  }

  # Rule 5: IP Reputation List
  rule {
    name     = "aws-managed-ip-reputation"
    priority = 40

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesAmazonIpReputationList"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-${var.env_name}-alb-ip-reputation"
      sampled_requests_enabled   = true
    }
  }

  # Rule 6: Geo blocking (optional)
  dynamic "rule" {
    for_each = length(var.alb_waf_blocked_countries) > 0 ? [1] : []

    content {
      name     = "geo-blocking"
      priority = 50

      action {
        block {}
      }

      statement {
        geo_match_statement {
          country_codes = var.alb_waf_blocked_countries
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.project_name}-${var.env_name}-alb-geo-block"
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-${var.env_name}-alb-waf"
    sampled_requests_enabled   = true
  }

  # Custom response bodies
  custom_response_body {
    key          = "rate_limit_exceeded"
    content      = jsonencode({
      error   = "Rate limit exceeded. Please try again later."
      code    = 429
      message = "Too many requests from your IP address."
    })
    content_type = "APPLICATION_JSON"
  }

  tags = {
    Name        = "${var.project_name}-${var.env_name}-alb-waf"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}

##########################################################
# Associate WAF with ALB
##########################################################

resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = module.alb.arn
  web_acl_arn  = aws_wafv2_web_acl.alb.arn
}

##########################################################
# CloudWatch Log Group for ALB WAF Logs
##########################################################

resource "aws_cloudwatch_log_group" "alb_waf" {
  name              = "/aws/wafv2/${var.project_name}-${var.env_name}-alb"
  retention_in_days = var.alb_waf_log_retention_days

  tags = {
    Name        = "${var.project_name}-${var.env_name}-alb-waf-logs"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}

##########################################################
# WAF Logging Configuration
##########################################################

resource "aws_wafv2_web_acl_logging_configuration" "alb" {
  resource_arn            = aws_wafv2_web_acl.alb.arn
  log_destination_configs = [aws_cloudwatch_log_group.alb_waf.arn]

  redacted_fields {
    single_header {
      name = "authorization"
    }
  }

  redacted_fields {
    single_header {
      name = "cookie"
    }
  }
}