resource "aws_cloudwatch_event_rule" "cloudwatch_lambda_glue_event_rule" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_lambda_glue_alerts") ? 1 : 0

  name                = format("%s-%s-%s", var.product_name, var.environment_code, "de-glue-alerts")
  description         = "Run lambda when glue job fails"
  event_pattern = <<EOF
{
  "source": ["aws.glue"],
  "detail-type": ["Glue Job State Change"],
  "detail": {
    "state": ["FAILED", "STOPPED", "TIMEOUT"]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "cloudwatch_lambda_glue_event_target" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_lambda_glue_alerts") ? 1 : 0

  arn  = aws_lambda_function.lambda_glue_alerts[0].arn
  rule = aws_cloudwatch_event_rule.cloudwatch_lambda_glue_event_rule[0].id
}

resource "aws_lambda_permission" "allow_cloudwatch_to_access_lambda_glue_alerts" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_lambda_glue_alerts") ? 1 : 0

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_glue_alerts[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cloudwatch_lambda_glue_event_rule[0].arn
}

resource "aws_sns_topic" "data_glue_alerts" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_lambda_glue_alerts") ? 1 : 0

  name = format("%s-%s-%s", var.product_name, var.environment_code, "data-alerts")
}

resource "aws_sns_topic_subscription" "email_target_data_team_data_alerts" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_data_team_sns_subscription") ? 1 : 0

  topic_arn = aws_sns_topic.data_glue_alerts[0].arn
  protocol  = "email"
  endpoint = var.email_target_data_team[var.environment_code]
}
