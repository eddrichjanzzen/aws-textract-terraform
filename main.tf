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

# random string generator
resource "random_string" "id" {
  length = 5
  special = false
  upper = false
}

# S3 Bucket for new Documents
resource "aws_s3_bucket" "new_documents" {
  bucket = "${var.new_documents_bucket_name}-${random_string.id.result}"
}

# S3 Bucket for new Documents Policy
resource "aws_s3_bucket_policy" "new_documents" {
  bucket                = aws_s3_bucket.new_documents.id
  policy                = <<POLICY
{
  "Version" : "2012-10-17",
  "Id" : "",
  "Statement" : [
    {
      "Sid" : "First",
      "Effect": "Allow",
      "Action": "s3:*",
      "Principal": {
        "AWS": "${aws_iam_role.lambda_service_role.arn}"
      },
      "Resource": [
        "${aws_s3_bucket.new_documents.arn}"
      ]
    }
  ]   
}
POLICY
}


# S3 Bucket for Textract Results
resource "aws_s3_bucket" "textract_results" {
  bucket = "${var.textract_results_bucket_name}-${random_string.id.result}"
}

# S3 Bucket Policy
resource "aws_s3_bucket_policy" "textract_results" {
  bucket                = aws_s3_bucket.textract_results.id
  policy                = <<POLICY
{
  "Version" : "2012-10-17",
  "Id" : "",
  "Statement" : [
    {
      "Sid" : "First",
      "Effect": "Allow",
      "Action": "s3:*",
      "Principal": {
        "AWS": "${aws_iam_role.lambda_service_role.arn}"
      },
      "Resource": [
        "${aws_s3_bucket.textract_results.arn}"
      ]
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
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

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
  description = "Provides write permissions to CloudWatch Logs, Access Dynamodb, SQS, s3, and Textract"
  path        = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "lambda:*",
        "logs:*",
        "sqs:*",
        "textract:*",
        "dynamodb:*",
        "s3:*"
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

# Document Doc lambda
resource "aws_lambda_function" "docproc" {
  function_name = var.docproc_function_name

  filename         = var.docproc_function_filename
  source_code_hash = filebase64sha256(var.docproc_archive_file_output_path)

  role    = aws_iam_role.lambda_service_role.arn
  handler = var.docproc_function_handler
  runtime = var.aws_lambda_function_runtime

  # specify utils layer here
  layers = [aws_lambda_layer_version.utils.arn]

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment,
    aws_cloudwatch_log_group.docproc
  ]

  environment {
    variables = {
      SYNC_QUEUE_URL = aws_sqs_queue.sync_queue.id
      ASYNC_QUEUE_URL = aws_sqs_queue.async_queue.id
    }
  }
}

resource "aws_cloudwatch_log_group" "docproc" {
  name              = "/aws/lambda/${var.docproc_function_name}"
  retention_in_days = 14
}


resource "aws_lambda_event_source_mapping" "docproc" {
  event_source_arn  = aws_dynamodb_table.document_input_table.stream_arn
  function_name     = aws_lambda_function.docproc.arn
  starting_position = "LATEST"

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment
  ]

}

data "archive_file" "docproc" {
  type        = "zip"
  source_file = var.docproc_archive_file_source_file
  output_path = var.docproc_archive_file_output_path
}

# Document Doc lambda
resource "aws_lambda_function" "syncproc" {
  function_name = var.syncproc_function_name

  filename         = var.syncproc_function_filename
  source_code_hash = filebase64sha256(var.syncproc_archive_file_output_path)

  role    = aws_iam_role.lambda_service_role.arn
  handler = var.syncproc_function_handler
  timeout  = var.syncproc_function_timeout
  runtime = var.aws_lambda_function_runtime

  # specify utils layer here
  layers = [aws_lambda_layer_version.utils.arn]

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment,
    aws_cloudwatch_log_group.syncproc
  ]

  environment {
    variables = {
      OUTPUT_TABLE = aws_dynamodb_table.document_output_table.id,
      TEXTRACT_RESULTS_S3 = aws_s3_bucket.textract_results.id
    }
  }
}

resource "aws_cloudwatch_log_group" "syncproc" {
  name              = "/aws/lambda/${var.syncproc_function_name}"
  retention_in_days = 14
}

data "archive_file" "syncproc" {
  type        = "zip"
  source_file = var.syncproc_archive_file_source_file
  output_path = var.syncproc_archive_file_output_path
}

resource "aws_lambda_event_source_mapping" "syncproc" {
  event_source_arn = aws_sqs_queue.sync_queue.arn
  enabled = true
  function_name = var.syncproc_function_name
  batch_size = var.syncproc_event_source_mapping_batch_size

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment
  ]

}

# S3proc Lambda

resource "aws_lambda_function" "s3proc" {
  filename      = var.s3proc_function_filename
  function_name = var.s3proc_function_name
  
  source_code_hash = filebase64sha256(var.docproc_archive_file_output_path)
  
  role          = aws_iam_role.lambda_service_role.arn
  handler       = var.s3proc_function_handler
  runtime       = var.aws_lambda_function_runtime

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment,
    aws_cloudwatch_log_group.s3proc
  ]

  # specify utils layer here
  layers = [aws_lambda_layer_version.utils.arn]

  environment {
    variables = {
      DOCUMENTS_TABLE = aws_dynamodb_table.document_input_table.id
    }
  }
}

resource "aws_cloudwatch_log_group" "s3proc" {
  name              = "/aws/lambda/${var.s3proc_function_name}"
  retention_in_days = 14
}

data "archive_file" "s3proc" {
  type        = "zip"
  source_file = var.s3proc_archive_file_source_file
  output_path = var.s3proc_archive_file_output_path
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:*"
  function_name = aws_lambda_function.s3proc.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.new_documents.arn
}

resource "aws_s3_bucket_notification" "s3proc" {
  bucket = aws_s3_bucket.new_documents.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3proc.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_permission.allow_bucket,
    aws_iam_policy.lambda_service_role_policy
  ]

}


# Lambda Layer 
resource "aws_lambda_layer_version" "utils" {
  filename   = var.lambda_layer_filename
  layer_name = var.lambda_layer_layer_name

  compatible_runtimes = [var.aws_lambda_function_runtime]
}


# Archive_file for lambda layer
data "archive_file" "utils" {
  type        = "zip"
  source_dir = var.lambda_layer_archive_file_source_dir
  output_path = var.lambda_layer_archive_file_output_path
}