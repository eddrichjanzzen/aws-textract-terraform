# AWS SQS - Sync Queue
resource "aws_sqs_queue" "sync_queue" {
  name                       = var.sync_queue_name
  visibility_timeout_seconds = var.sync_queue_visibility_timeout
}

# AWS SQS Queue Policy
resource "aws_sqs_queue_policy" "sync_queue" {
  queue_url             =  aws_sqs_queue.sync_queue.id
  policy                = <<POLICY
{
  "Version" : "2012-10-17",
  "Id" : "sqspolicy",
  "Statement" : [
    {
      "Sid" : "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:*",
      "Resource": "${aws_sqs_queue.sync_queue.arn}"
    }
  ]   
}
POLICY
}

# AWS SQS - Async Queue
resource "aws_sqs_queue" "async_queue" {
  name                       = var.async_queue_name
  visibility_timeout_seconds = var.sync_queue_visibility_timeout
}

# AWS SQS Queue policy
resource "aws_sqs_queue_policy" "async_queue" {
  queue_url             =  aws_sqs_queue.async_queue.id
  policy                = <<POLICY
{
  "Version" : "2012-10-17",
  "Id" : "sqspolicy",
  "Statement" : [
    {
      "Sid" : "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:*",
      "Resource": "${aws_sqs_queue.async_queue.arn}"
    }
  ]   
}
POLICY
}


# AWS SQS - Async Queue
resource "aws_sqs_queue" "async_complete_queue" {
  name                       = var.async_queue_name
  visibility_timeout_seconds = var.sync_queue_visibility_timeout
}

# AWS SQS Queue policy
resource "aws_sqs_queue_policy" "async_complete_queue" {
  queue_url             =  aws_sqs_queue.async_complete_queue.id
  policy                = <<POLICY
{
  "Version" : "2012-10-17",
  "Id" : "sqspolicy",
  "Statement" : [
    {
      "Sid" : "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:*",
      "Resource": "${aws_sqs_queue.async_complete_queue.arn}"
    }
  ]   
}
POLICY
}

resource "aws_sns_topic" "job_notification" {
  name = var.job_notification_service_name
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
}