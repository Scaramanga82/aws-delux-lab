resource "aws_iam_role" "lambda_glue_alerts" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_lambda_glue_alerts") ? 1 : 0

  name = format("%s-%s-%s", var.product_name, var.environment_code, "lambda-glue-alerts")

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda_glue_alerts" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_lambda_glue_alerts") ? 1 : 0

  function_name = format("%s-%s-%s", var.product_name, var.environment_code, "lambda-glue-alerts")
  role          = aws_iam_role.lambda_glue_alerts[0].arn
  image_uri     = lookup(var.aws_lambda_glue_alerts_image, var.environment_code)
  package_type  = "Image"
  timeout       = 900

  environment {
    variables = {
      ENV    = var.environment_code
      REGION = lookup(var.aws_region, var.environment_code)
      SNS_ARN = lookup(var.aws_sns_glue_arn, var.environment_code)
      DATA_ALERTS_SNS = lookup(var.aws_sns_data_alerts_arn, var.environment_code)
      DATA_ENGINEERING_SNS = lookup(var.aws_sns_data_engineering_arn, var.environment_code)
    }
  }

  lifecycle {
    ignore_changes = [
      image_uri
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_glue_alerts_AWSLambdaBasicExecutionRole[0],
    aws_iam_role_policy_attachment.lambda_glue_alerts_AmazonSNSFullAccess[0]
  ]

  tags = {
    Name  = format("%s-%s-%s", var.product_name, var.environment_code, "lambda-glue-alerts"),
    ENV   = var.environment_code,
    Owner = var.owner
  }
}

resource "aws_lambda_alias" "lambda_glue_alerts_alias" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_lambda_glue_alerts") ? 1 : 0

  name             = format("%s-%s-%s", var.product_name, var.environment_code, "lambda-glue-alerts-alias")
  function_name    = aws_lambda_function.lambda_glue_alerts[0].arn
  function_version = "$LATEST"
}

resource "aws_iam_role_policy_attachment" "lambda_glue_alerts_AWSLambdaBasicExecutionRole" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_lambda_glue_alerts") ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_glue_alerts[0].name
}

resource "aws_iam_role_policy_attachment" "lambda_glue_alerts_AmazonSNSFullAccess" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_lambda_glue_alerts") ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
  role       = aws_iam_role.lambda_glue_alerts[0].name
}