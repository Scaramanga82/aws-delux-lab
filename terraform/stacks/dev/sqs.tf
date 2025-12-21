##########################################################
# Main Queue
##########################################################
module "sqs_main" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "5.1.0"

  name = "${var.project_name}-${var.env_name}-main-queue"

  # Queue settings
  visibility_timeout_seconds = var.sqs_visibility_timeout
  message_retention_seconds  = var.sqs_message_retention
  receive_wait_time_seconds  = var.sqs_receive_wait_time
  delay_seconds              = var.sqs_delay_seconds
  max_message_size           = var.sqs_max_message_size

  # Dead Letter Queue configuration
  redrive_policy = {
    deadLetterTargetArn = module.sqs_dlq.queue_arn
    maxReceiveCount     = var.sqs_max_receive_count
  }

  # Encryption
  sqs_managed_sse_enabled = var.sqs_encryption_enabled
  
  tags = {
    Name        = "${var.project_name}-${var.env_name}-main-queue"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}

##########################################################
# Dead Letter Queue
##########################################################
module "sqs_dlq" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "5.1.0"

  name = "${var.project_name}-${var.env_name}-main-dlq"

  # DLQ settings - longer retention period
  message_retention_seconds = var.sqs_dlq_retention
  
  # Encryption
  sqs_managed_sse_enabled = var.sqs_encryption_enabled

  tags = {
    Name        = "${var.project_name}-${var.env_name}-main-dlq"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}

##########################################################
# CloudWatch Alarms
##########################################################
resource "aws_cloudwatch_metric_alarm" "sqs_dlq_messages" {
  alarm_name          = "${var.project_name}-${var.env_name}-sqs-dlq-messages"
  alarm_description   = "Alert when messages appear in DLQ"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "300"
  statistic           = "Average"
  threshold           = "0"
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = module.sqs_dlq.queue_name
  }

  # Optional: SNS notification
  # alarm_actions = [var.sns_topic_arn]

  tags = {
    Name        = "${var.project_name}-${var.env_name}-sqs-dlq-messages"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "sqs_main_age" {
  alarm_name          = "${var.project_name}-${var.env_name}-sqs-message-age"
  alarm_description   = "Alert when messages are too old"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "600" # 10 minutes
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = module.sqs_main.queue_name
  }

  # Optional: SNS notification
  # alarm_actions = [var.sns_topic_arn]

  tags = {
    Name        = "${var.project_name}-${var.env_name}-sqs-message-age"
    Project     = var.project_name
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}
