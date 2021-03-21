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
      "Action": "sqs:SendMessage",
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

# AWS Lambda Function

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
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

data "archive_file" "this" {
  type        = "zip"
  source_file = var.archive_file_source_file
  output_path = var.archive_file_output_path
}


resource "aws_lambda_function" "this" {
  function_name = var.aws_lambda_function_function_name

  filename         = var.aws_lambda_function_filename
  source_code_hash = filebase64sha256(var.archive_file_output_path)

  role    = aws_iam_role.iam_for_lambda.arn
  handler = var.aws_lambda_function_handler
  runtime = var.aws_lambda_function_runtime

  environment {
    variables = {
      greeting = "Hello"
    }
  }
}


