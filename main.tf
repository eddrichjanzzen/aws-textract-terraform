# AWS SQS Queue
resource "aws_sqs_queue" "sync_queue" {
  name                  = var.aws_sqs_queue_name
}

# AWS SQS Queue policy
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
      "Resource": "${aws_sqs_queue.sync_queue.arn}",
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


# DynamoDB Table Document Input
resource "aws_dynamodb_table" "document_input_table" {
  name           = var.document_input_table_name
  hash_key       = var.document_input_table_hash_key
  read_capacity  = var.document_input_table_read_capacity
  write_capacity = var.document_input_table_write_capacity

  attribute {
    name = var.document_input_table_hash_key
    type = "S"
  }
}


# DynamoDB Table Document Output
resource "aws_dynamodb_table" "document_output_table" {
  name           = var.document_output_table_name
  hash_key       = var.document_output_table_hash_key
  read_capacity  = var.document_output_table_read_capacity
  write_capacity = var.document_output_table_write_capacity

  attribute {
    name = var.document_output_table_hash_key
    type = "S"
  }
}


# AWS S3 bucket
resource "aws_s3_bucket" "this" {
  bucket = var.aws_s3_bucket_name
}

# AWS S3 bucket notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.this.id

  queue { 
    queue_arn = aws_sqs_queue.sync_queue.arn
    events = ["s3:ObjectCreated:Put"]
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
  description = "Provides write permissions to CloudWatch Logs, Access Dynamodb, SQS, and Textract"
  path        = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "lambda:*"
      ],
      "Resource": "*"
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
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "dynamodb:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_service_role.name
  policy_arn = aws_iam_policy.lambda_service_role_policy.arn
}

# Document Proc lambda

data "archive_file" "docproc" {
  type        = "zip"
  source_file = var.docproc_archive_file_source_file
  output_path = var.docproc_archive_file_output_path
}

resource "aws_lambda_function" "docproc" {
  function_name = var.docproc_function_name

  filename         = var.docproc_function_filename
  source_code_hash = filebase64sha256(var.docproc_archive_file_output_path)

  role    = aws_iam_role.lambda_service_role.arn
  handler = var.docproc_function_handler
  runtime = var.aws_lambda_function_runtime

  # specify utils layer here
  layers = [aws_lambda_layer_version.utils.arn]

  environment {
    variables = {
      SYNC_QUEUE_URL = aws_sqs_queue.sync_queue.id
      ASYNC_QUEUE_URL = ""
    }
  }
}

resource "aws_lambda_event_source_mapping" "docproc" {
  event_source_arn = aws_sqs_queue.sync_queue.arn
  enabled = true
  function_name = var.docproc_function_name
  batch_size = var.docproc_event_source_mapping_batch_size
}


# Archive_file for lambda layer
data "archive_file" "utils" {
  type        = "zip"
  source_dir = var.lambda_layer_archive_file_source_dir
  output_path = var.lambda_layer_archive_file_output_path
}


# Lambda Layer 
resource "aws_lambda_layer_version" "utils" {
  filename   = var.lambda_layer_filename
  layer_name = var.lambda_layer_layer_name

  compatible_runtimes = [var.aws_lambda_function_runtime]
}

