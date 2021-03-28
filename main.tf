# AWS SQS Queue
resource "aws_sqs_queue" "this" {
  name                  = var.aws_sqs_queue_name
}

# AWS SQS Queue policy
resource "aws_sqs_queue_policy" "this" {
  queue_url             =  aws_sqs_queue.this.id
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
      "Resource": "${aws_sqs_queue.this.arn}",
      "Condition" : {
        "ArnEquals": { 
          "aws:SourceArn": "${aws_s3_bucket.this.arn}"
        }
      }
    }
  ]   
}
POLICY
}

# AWS S3 bucket
resource "aws_s3_bucket" "this" {
  bucket = var.aws_s3_bucket_name
}

# AWS S3 bucket notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.this.id

  queue { 
    queue_arn = aws_sqs_queue.this.arn
    events = ["s3:ObjectCreated:Put"]
  }

}

# DynamoDB Table
resource "aws_dynamodb_table" "this" {
  name           = var.aws_dynamodb_table_name
  hash_key       = var.aws_dynamodb_table_hash_key
  read_capacity  = var.aws_dynamodb_table_read_capacity
  write_capacity = var.aws_dynamodb_table_write_capacity

  attribute {
    name = var.aws_dynamodb_table_hash_key
    type = "S"
  }

}

# Lambda IAM Role and Policy
resource "aws_iam_role" "lambda_service_role" {
  name = var.lambda_service_role_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_service_role_policy" {
  name        = var.lambda_service_role_policy_name
  description = "Provides write permissions to CloudWatch Logs, access Dynamodb, and SQS"
  path        = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "lambda:InvokeFunction",
      "Resource": "${aws_lambda_function.this.arn}"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
          "logs:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
          "sqs:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "",
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
          "textract:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_service_role.name
  policy_arn = aws_iam_policy.lambda_service_role_policy.arn
}


data "archive_file" "this" {
  type        = "zip"
  source_file = var.archive_file_source_file
  output_path = var.archive_file_output_path
}


resource "aws_lambda_function" "this" {
  function_name = var.aws_lambda_function_function_name

  filename         = var.aws_lambda_function_filename
  source_code_hash = filebase64sha256(var.archive_file_output_path)

  role    = aws_iam_role.lambda_service_role.arn
  handler = var.aws_lambda_function_handler
  runtime = var.aws_lambda_function_runtime

  environment {
    variables = {
      s3_bucket_name = var.aws_s3_bucket_name
    }
  }
}


# s3 bucket upload trigger
resource "aws_lambda_event_source_mapping" "this" {
  event_source_arn = aws_sqs_queue.this.arn
  enabled = true
  function_name = var.aws_lambda_function_function_name
  batch_size = var.aws_lambda_event_source_mapping_batch_size
}