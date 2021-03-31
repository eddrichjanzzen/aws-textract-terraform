# General
variable "aws_region" {
  type        = string
  description = "Used AWS Region."    
}

variable "aws_account" {
  type        = string
  description = "Used AWS Account."    
}

variable "aws_role" {
  type        = string
  description = "Used AWS role."
}

variable "namespace" {
  type        = string
  description = "Namespace."
}

variable "environment" {
  type        = string
  description = "Environment."
}

# Lambda Global Runtime 
variable "aws_lambda_function_runtime" {
  type        = string
  description = "Required - runtime of the lambda function, python, node, c#, etc"    
}


# SQS queue - Sync

variable "sync_queue_name" {
  type        = string
  description = "Required - Name of the sqs queue."    
}

variable "sync_queue_visibility_timeout" {
  type        = string
  description = "Required - visisbility timeout of the sqs queue, make sure this is equal or greater than the timeout of the lambda function"    
}


# SQS queue - Async

variable "async_queue_name" {
  type        = string
  description = "Required - Name of the sqs queue."    
}

variable "async_queue_visibility_timeout" {
  type        = string
  description = "Required - visisbility timeout of the sqs queue, make sure this is equal or greater than the timeout of the lambda function"    
}


# S3 Bucket - new 

variable "new_documents_bucket_name" {
  type        = string
  description = "Required - Name of the s3 bucket."    
}

# S3 Bucket - results

variable "textract_results_bucket_name" {
  type        = string
  description = "Required - Name of the s3 bucket."    
}


# DynamoDB Table Document Input
variable "document_input_table_name" {
  type        = string
  description = "The name of the table, this needs to be unique within a region."
}

variable "document_input_table_hash_key" {
  type        = string
  description = "(Required, Forces new resource) The attribute to use as the hash (partition) key. Must also be defined as an attribute, see below."
}

variable "document_input_table_read_capacity" {
  type        = string
  description = "(Optional) The number of read units for this table. If the billing_mode is PROVISIONED, this field is required."
}

variable "document_input_table_write_capacity" {
  type        = string
  description = "(Optional) The number of write units for this table. If the billing_mode is PROVISIONED, this field is required."
}

# DynamoDB Table Document Output
variable "document_output_table_name" {
  type        = string
  description = "The name of the table, this needs to be unique within a region."
}

variable "document_output_table_hash_key" {
  type        = string
  description = "(Required, Forces new resource) The attribute to use as the hash (partition) key. Must also be defined as an attribute, see below."
}

variable "document_output_table_read_capacity" {
  type        = string
  description = "(Optional) The number of read units for this table. If the billing_mode is PROVISIONED, this field is required."
}

variable "document_output_table_write_capacity" {
  type        = string
  description = "(Optional) The number of write units for this table. If the billing_mode is PROVISIONED, this field is required."
}


# S3proc Lambda
variable "s3proc_function_name" {
  type        = string
  description = "Required - function_name of the s3proc function"    
}

variable "s3proc_function_filename" {
  type        = string
  description = "Required - filename of s3proc function ends in filename.zip"    
}

variable "s3proc_function_handler" {
  type        = string
  description = "Required - Name of the lambda handler"    
}

# #3proc Archieve File
variable "s3proc_archive_file_source_file" {
  type        = string
  description = "Required - source to archive for lambda function eg. lambda_function.py"    
}

variable "s3proc_archive_file_output_path" {
  type        = string
  description = "Required - output path of the archive file for the lambda function eg. lambda_function.zip"    
}


# Docproc Lambda
variable "docproc_function_name" {
  type        = string
  description = "Required - function_name of the docproc function"    
}

variable "docproc_function_filename" {
  type        = string
  description = "Required - filename of docproc function ends in filename.zip"    
}

variable "docproc_function_handler" {
  type        = string
  description = "Required - Name of the lambda handler"    
}


# Docproc Archieve File
variable "docproc_archive_file_source_file" {
  type        = string
  description = "Required - source to archive for lambda function eg. lambda_function.py"    
}

variable "docproc_archive_file_output_path" {
  type        = string
  description = "Required - output path of the archive file for the lambda function eg. lambda_function.zip"    
}

# Syncproc Lambda
variable "syncproc_function_name" {
  type        = string
  description = "Required - function_name of the syncproc function"    
}

variable "syncproc_function_filename" {
  type        = string
  description = "Required - filename of syncproc function ends in filename.zip"    
}

variable "syncproc_function_handler" {
  type        = string
  description = "Required - Name of the lambda handler"    
}

variable "syncproc_function_timeout" {
  type        = number
  description = "Required - timeout of syncproc function, need to set greater than 3 seconds"    
}

# Syncproc Archieve File
variable "syncproc_archive_file_source_file" {
  type        = string
  description = "Required - source to archive for lambda function eg. lambda_function.py"    
}

variable "syncproc_archive_file_output_path" {
  type        = string
  description = "Required - output path of the archive file for the lambda function eg. lambda_function.zip"    
}



# Lambda SQS Event Source

variable "syncproc_event_source_mapping_batch_size" {
  type        = number
  description = "Required - Number of messages you want to send the sqs queue at a time. eg. 1 message at a time"    
}

# Textract Lambda Service Role

variable "lambda_service_role_name" {
  type        = string
  description = "Required - the service role name for the lambda function"    
}

variable "lambda_service_role_policy_name" {
  type        = string
  description = "Required - the service role policy name for the lambda function"    
}


# Lambda Layer 

variable "lambda_layer_filename" {
  type        = string
  description = "Required - filename of the lambda layer"    
}

variable "lambda_layer_layer_name" {
  type        = string
  description = "Required - layer name of the utils lambda layer"    
}

# Lambda Layer Archive file

variable "lambda_layer_archive_file_source_dir" {
  type        = string
  description = "Required - source directory archive for lambda function eg. /src/lambda-layers"    
}

variable "lambda_layer_archive_file_output_path" {
  type        = string
  description = "Required - output path of the archive file for the lambda function eg. lambda_function.zip"    
}