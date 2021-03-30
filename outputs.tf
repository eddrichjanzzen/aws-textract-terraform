# SQS queue - Sync
output "sync_sqs_queue_arn" {
  value       = aws_sqs_queue.sync_queue.arn
  description = "Full ARN of the sqs queue."
}

output "sync_sqs_queue_name" {
  value       = aws_sqs_queue.sync_queue.name
  description = "The name of the sqs queue."
}

output "sync_sqs_queue_id" {
  value       = aws_sqs_queue.sync_queue.id
  description = "The name of the id queue."
}

# SQS queue - Async
output "async_sqs_queue_arn" {
  value       = aws_sqs_queue.async_queue.arn
  description = "Full ARN of the sqs queue."
}

output "async_sqs_queue_name" {
  value       = aws_sqs_queue.async_queue.name
  description = "The name of the sqs queue."
}

output "async_sqs_queue_id" {
  value       = aws_sqs_queue.async_queue.id
  description = "The name of the id queue."
}


# S3 bucket - Source bucket
output "new_documents_bucket_arn" {
  value       = aws_s3_bucket.new_documents.arn
  description = "Full ARN of the sqs queue."
}

output "new_documents_bucket_name" {
  value       = aws_s3_bucket.new_documents.bucket
  description = "The name of the sqs queue."
}


# DynamoDB Table - Document Input Table
output "document_input_table_arn" {
  value       = aws_dynamodb_table.document_input_table.arn
  description = "The arn of the table"
}

output "document_input_table_id" {
  value       = aws_dynamodb_table.document_input_table.id
  description = "The name of the table"
}

output "document_input_table_stream_arn" {
  value       = aws_dynamodb_table.document_input_table.stream_arn
  description = " The ARN of the Table Stream. Only available when stream_enabled = true"
}

output "document_input_table_stream_label" {
  value       = aws_dynamodb_table.document_input_table.stream_label
  description = "A timestamp, in ISO 8601 format, for this stream. Note that this timestamp is not a unique identifier for the stream on its own. However, the combination of AWS customer ID, table name and this field is guaranteed to be unique. It can be used for creating CloudWatch Alarms. Only available when stream_enabled = true"
}


# DynamoDB Table - Document Input Table
output "document_output_table_arn" {
  value       = aws_dynamodb_table.document_output_table.arn
  description = "The arn of the table"
}

output "document_output_table_id" {
  value       = aws_dynamodb_table.document_output_table.id
  description = "The name of the table"
}

output "document_output_table_stream_arn" {
  value       = aws_dynamodb_table.document_output_table.stream_arn
  description = " The ARN of the Table Stream. Only available when stream_enabled = true"
}

output "document_output_table_stream_label" {
  value       = aws_dynamodb_table.document_output_table.stream_label
  description = "A timestamp, in ISO 8601 format, for this stream. Note that this timestamp is not a unique identifier for the stream on its own. However, the combination of AWS customer ID, table name and this field is guaranteed to be unique. It can be used for creating CloudWatch Alarms. Only available when stream_enabled = true"
}


# Lambda Runtime
output "aws_lambda_function_runtime" {
  value       = aws_lambda_function.docproc.runtime
  description = "The runtime of the textract lambda function"
}

# Doc Proc function
output "docproc_function_name" {
  value       = aws_lambda_function.docproc.function_name
  description = "The name of the textract lambda function"
}

output "docproc_function_handler" {
  value       = aws_lambda_function.docproc.handler
  description = "The handler of the textract lambda function"
}


# S3proc function
output "S3proc_function_name" {
  value       = aws_lambda_function.s3proc.function_name
  description = "The name of the textract lambda function"
}

output "S3proc_function_handler" {
  value       = aws_lambda_function.s3proc.handler
  description = "The handler of the textract lambda function"
}


# Utils Lambda Layer

output "utils_lambda_layer_name" {
  value       = aws_lambda_layer_version.utils.layer_name
  description = "The name of the utils lambda layer"
}

output "utils_lambda_layer_arn" {
  value        = aws_lambda_layer_version.utils.arn
  description = "The arn of the utils lambda layer"    
}