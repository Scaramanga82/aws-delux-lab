resource "aws_cloudwatch_event_rule" "cloudwatch_rds_snapshot_partial_export_to_s3_event_rule" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_lambda_rds_snapshot_partial_export_to_s3") ? 1 : 0

  name                = format("%s-%s-%s", var.product_name, var.environment_code, "lambda-rds-snapshot-partial-export-to-s3-cron")
  description         = "Run lambda every day"
  schedule_expression = "cron(0 2 * * ? *)"
  is_enabled          = false

}

resource "aws_cloudwatch_event_target" "cloudwatch_rds_snapshot_partial_export_to_s3_event_target" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_lambda_rds_snapshot_partial_export_to_s3") ? 1 : 0

  arn  = aws_lambda_function.lambda_rds_snapshot_partial_export_to_s3[0].arn
  rule = aws_cloudwatch_event_rule.cloudwatch_rds_snapshot_partial_export_to_s3_event_rule[0].id
}

resource "aws_lambda_permission" "allow_cloudwatch_to_access_lambda_rds_snapshot_partial_export_to_s3" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_lambda_rds_snapshot_partial_export_to_s3") ? 1 : 0

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_rds_snapshot_partial_export_to_s3[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cloudwatch_rds_snapshot_partial_export_to_s3_event_rule[0].arn
}


resource "aws_cloudwatch_event_rule" "cloudwatch_rds_snapshot_partial_export_to_s3_event_rule_automatic" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_lambda_rds_snapshot_partial_export_to_s3_automatic") ? 1 : 0

  name        = format("%s-%s-%s", var.product_name, var.environment_code, "lambda-rds-snapshot-partial-export-to-s3-automatic")
  description = "Trigger Lambda function when a new postgresql cluster system snapshot is created"
  event_pattern = jsonencode({
    "source": ["aws.rds"],
    "detail-type": ["RDS DB Cluster Snapshot Event"],
    "account": ["744451532675"],
    "region": ["eu-central-1"],
    "detail": {
      "SourceType": ["CLUSTER_SNAPSHOT"],
      "SourceArn": [{
      "prefix": "arn:aws:rds:eu-central-1:744451532675:cluster-snapshot:rds:data-team-prod-copy-postgresql-cluster-"
      }],
      "EventID": ["RDS-EVENT-0169"]
    }
  })
  is_enabled          = false
}

resource "aws_cloudwatch_event_target" "cloudwatch_rds_snapshot_partial_export_to_s3_event_target_automatic" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_lambda_rds_snapshot_partial_export_to_s3_automatic") ? 1 : 0

  arn  = aws_lambda_function.lambda_rds_snapshot_partial_export_to_s3[0].arn
  rule = aws_cloudwatch_event_rule.cloudwatch_rds_snapshot_partial_export_to_s3_event_rule_automatic[0].id
}

resource "aws_lambda_permission" "allow_cloudwatch_to_access_lambda_rds_snapshot_partial_export_to_s3_automatic" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_lambda_rds_snapshot_partial_export_to_s3_automatic") ? 1 : 0

  statement_id  = "AllowExecutionFromCloudWatchAutomatic"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_rds_snapshot_partial_export_to_s3[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cloudwatch_rds_snapshot_partial_export_to_s3_event_rule_automatic[0].arn
}
