# SQS queue
output "aws_sqs_queue_arn" {
  value       = aws_sqs_queue.this.arn
  description = "Full ARN of the sqs queue."
}

output "aws_sqs_queue_name" {
  value       = aws_sqs_queue.this.name
  description = "The name of the sqs queue."
}


# S3 bucket
output "aws_s3_bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "Full ARN of the sqs queue."
}

output "aws_s3_bucket_name" {
  value       = aws_s3_bucket.this.bucket
  description = "The name of the sqs queue."
}


# DynamoDB Table
output "aws_dynamodb_table_arn" {
  value       = aws_dynamodb_table.this.arn
  description = "The arn of the table"
}

output "aws_dynamodb_table_id" {
  value       = aws_dynamodb_table.this.id
  description = "The name of the table"
}

output "aws_dynamodb_table_stream_arn" {
  value       = aws_dynamodb_table.this.stream_arn
  description = " The ARN of the Table Stream. Only available when stream_enabled = true"
}

output "aws_dynamodb_table_stream_label" {
  value       = aws_dynamodb_table.this.stream_label
  description = "A timestamp, in ISO 8601 format, for this stream. Note that this timestamp is not a unique identifier for the stream on its own. However, the combination of AWS customer ID, table name and this field is guaranteed to be unique. It can be used for creating CloudWatch Alarms. Only available when stream_enabled = true"
}

# Lambda function
output "aws_lambda_function_name" {
  value       = aws_lambda_function.this.name
  description = "The name of the lambda function"
}

output "aws_lambda_function_handler" {
  value       = aws_lambda_function.this.handler
  description = "The handler of the lambda function"
}

output "aws_lambda_function_runtime" {
  value       = aws_lambda_function.this.runtime
  description = "The runtime of the lambda function"
}