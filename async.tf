# S3batchproc Lambda

resource "aws_lambda_function" "s3batchproc" {
  filename      = var.s3batchproc_function_filename
  function_name = var.s3batchproc_function_name
  
  source_code_hash = filebase64sha256(var.s3batchproc_archive_file_output_path)
  
  role          = aws_iam_role.lambda_service_role.arn
  handler       = var.s3batchproc_function_handler
  runtime       = var.aws_lambda_function_runtime

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment,
    aws_cloudwatch_log_group.s3batchproc
  ]

  # specify utils layer here
  layers = [aws_lambda_layer_version.utils.arn]

  environment {
    variables = {
      DOCUMENTS_TABLE = aws_dynamodb_table.document_input_table.id
    }
  }
}

resource "aws_cloudwatch_log_group" "s3batchproc" {
  name              = "/aws/lambda/${var.s3batchproc_function_name}"
  retention_in_days = 14
}

data "archive_file" "s3batchproc" {
  type        = "zip"
  source_file = var.s3batchproc_archive_file_source_file
  output_path = var.s3batchproc_archive_file_output_path
}

resource "aws_lambda_permission" "allow_s3batchproc" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:*"
  function_name = aws_lambda_function.s3batchproc.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.existing_documents.arn
}

resource "aws_s3_bucket_notification" "s3batchproc" {
  bucket = aws_s3_bucket.new_documents.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3batchproc.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_permission.allow_s3batchproc,
    aws_iam_role_policy_attachment.lambda_policy_attachment
  ]

}

# Jobresultsproc Lambda

resource "aws_lambda_function" "jobresultsproc" {
  filename      = var.jobresultsproc_function_filename
  function_name = var.jobresultsproc_function_name
  
  source_code_hash = filebase64sha256(var.jobresultsproc_archive_file_output_path)
  
  role          = aws_iam_role.lambda_service_role.arn
  handler       = var.jobresultsproc_function_handler
  runtime       = var.aws_lambda_function_runtime

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment,
    aws_cloudwatch_log_group.jobresultsproc
  ]

  # specify utils layer here
  layers = [aws_lambda_layer_version.utils.arn]

  environment {
    variables = {
      OUTPUT_BUCKET = aws_s3_bucket.textract_results.id
      OUTPUT_TABLE = aws_dynamodb_table.document_output_table.id
    }
  }
}

resource "aws_cloudwatch_log_group" "jobresultsproc" {
  name              = "/aws/lambda/${var.jobresultsproc_function_name}"
  retention_in_days = 14
}

data "archive_file" "jobresultsproc" {
  type        = "zip"
  source_file = var.jobresultsproc_archive_file_source_file
  output_path = var.jobresultsproc_archive_file_output_path
}


# Asyncproc Lambda
resource "aws_lambda_function" "asyncproc" {
  filename      = var.asyncproc_function_filename
  function_name = var.asyncproc_function_name
  
  source_code_hash = filebase64sha256(var.asyncproc_archive_file_output_path)
  
  role          = aws_iam_role.lambda_service_role.arn
  handler       = var.asyncproc_function_handler
  runtime       = var.aws_lambda_function_runtime

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment,
    aws_cloudwatch_log_group.asyncproc
  ]

  # specify utils layer here
  layers = [aws_lambda_layer_version.utils.arn]

  environment {
    variables = {
      OUTPUT_BUCKET = aws_s3_bucket.textract_results.id
      OUTPUT_TABLE = aws_dynamodb_table.document_output_table.id
    }
  }
}

resource "aws_cloudwatch_log_group" "asyncproc" {
  name              = "/aws/lambda/${var.asyncproc_function_name}"
  retention_in_days = 14
}

data "archive_file" "asyncproc" {
  type        = "zip"
  source_file = var.asyncproc_archive_file_source_file
  output_path = var.asyncproc_archive_file_output_path
}

