resource "aws_iam_role" "lambda_rds_snapshot_partial_export_to_s3_st" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_lambda_rds_snapshot_partial_export_to_s3_st") ? 1 : 0

  name = format("%s-%s-%s", var.product_name, "stage", "lambda-rds-snapshot-partial-export-to-s3")

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

resource "aws_lambda_function" "lambda_rds_snapshot_partial_export_to_s3_st" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_lambda_rds_snapshot_partial_export_to_s3_st") ? 1 : 0

  function_name = format("%s-%s-%s", var.product_name, "stage", "lambda-rds-snapshot-partial-export-to-s3")
  role          = aws_iam_role.lambda_rds_snapshot_partial_export_to_s3_st[0].arn
  image_uri     = lookup(var.aws_lambda_rds_snapshot_partial_export_to_s3_image_st, var.environment_code)
  package_type  = "Image"
  timeout       = 900

  environment {
    variables = {
      ENV                 = var.environment_code
      PRODUCT_NAME        = var.product_name
      RDS_CLUSTER_ARN     = lookup(var.aws_lambda_rds_snapshot_partial_export_to_s3_rds_cluster_arn_st, var.environment_code)
      KMS_KEY_ARN         = lookup(var.aws_lambda_rds_snapshot_partial_export_to_s3_kms_key_arn_st, var.environment_code)
      EXPORT_IAM_ROLE_ARN = lookup(var.aws_lambda_rds_snapshot_partial_export_to_s3_iam_role_arn_st, var.environment_code)
      S3_BUCKET_NAME      = lookup(var.aws_lambda_rds_snapshot_partial_export_to_s3_bucket_name_st, var.environment_code)
    }
  }

  lifecycle {
    ignore_changes = [
      image_uri,
    ]
  }

  tags = {
    Name  = format("%s-%s-%s", var.product_name, "stage", "lambda-rds-snapshot-partial-export-to-s3"),
    ENV   = var.environment_code,
    Owner = var.owner,
    DataTeam-AWS-Cost = var.data_cost,
  }

}

resource "aws_lambda_alias" "lambda_rds_snapshot_partial_export_to_s3_st_alias" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_lambda_rds_snapshot_partial_export_to_s3_st") ? 1 : 0

  name             = format("%s-%s-%s", var.product_name, "stage", "lambda-rds-snapshot-partial-export-to-s3-alias")
  function_name    = aws_lambda_function.lambda_rds_snapshot_partial_export_to_s3_st[0].arn
  function_version = "$LATEST"
}

resource "aws_iam_role_policy_attachment" "lambda_rds_snapshot_partial_export_to_s3_st_AWSLambdaBasicExecutionRole" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_lambda_rds_snapshot_partial_export_to_s3_st") ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_rds_snapshot_partial_export_to_s3_st[0].name
}

resource "aws_cloudwatch_log_group" "lambda_rds_snapshot_partial_export_to_s3_st" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_lambda_rds_snapshot_partial_export_to_s3_st") ? 1 : 0

  name              = format("%s%s", "/aws/lambda/", format("%s-%s-%s", var.product_name, "stage", "lambda_rds_snapshot_partial_export_to_s3"))
  retention_in_days = 1
}

resource "aws_iam_role_policy" "lambda_rds_snapshot_partial_export_to_s3_st_policy" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_lambda_rds_snapshot_partial_export_to_s3_st") ? 1 : 0

  name   = format("%s-%s-%s", var.product_name, "stage", "lambda-rds-snapshot-partial-export-to-s3-policy")
  role   = aws_iam_role.lambda_rds_snapshot_partial_export_to_s3_st[0].id
  policy = data.aws_iam_policy_document.lambda_rds_snapshot_partial_export_to_s3_st_policy_document[0].json
}

data "aws_iam_policy_document" "lambda_rds_snapshot_partial_export_to_s3_st_policy_document" {
  count = lookup(lookup(var.deployment_flags, var.environment_code), "enable_lambda_rds_snapshot_partial_export_to_s3_st") ? 1 : 0

  statement {
    sid    = "LambdaExportToS3"
    effect = "Allow"
    actions = [
      "rds:DescribeDBClusterSnapshots",
      "rds:DescribeDBClusters",
      "rds:DescribeDBInstances",
      "rds:DescribeDBSnapshots",
      "rds:DescribeExportTasks",
      "rds:StartExportTask",
      "iam:PassRole"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "LambdaExportToS3Kms"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = [lookup(var.aws_lambda_rds_snapshot_partial_export_to_s3_kms_key_arn_st, var.environment_code)]
  }

  statement {
    sid    = "LambdaExportToS3KmsTestKey"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = [
      "arn:aws:kms:eu-central-1:744451532675:key/37a0dc03-db29-46d5-9040-b63be8e271d5"
    ]
  }

  statement {
    sid    = "AllowUserToListPostgresqlS3Backup"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetBucketAcl",
      "s3:ListBucketMultipartUploads"
    ]
    resources = [
      lookup(var.aws_lambda_rds_snapshot_partial_export_to_s3_bucket_arn_st, var.environment_code),
      format("%s/*", lookup(var.aws_lambda_rds_snapshot_partial_export_to_s3_bucket_arn_st, var.environment_code))
    ]
  }

  statement {
    sid    = "AllowUserToWritePostgresqlS3Backup"
    effect = "Allow"
    actions = [
      "s3:Put*",
      "s3:Get*",
      "s3:Describe*",
      "s3:DeleteObject*",
      "s3:List*",
      "s3:RestoreObject",
      "s3:Update*"
    ]
    resources = [
      lookup(var.aws_lambda_rds_snapshot_partial_export_to_s3_bucket_arn_st, var.environment_code),
      format("%s/*", lookup(var.aws_lambda_rds_snapshot_partial_export_to_s3_bucket_arn_st, var.environment_code))
    ]
  }
}
