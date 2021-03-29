# General
aws_region  = "ap-southeast-1"
aws_account = "182101634518"
namespace   = "shared"
environment = "production"
aws_role    = "OrganizationAccountAccessRole"

# SQS queue
aws_sqs_queue_name = "182191634518-ap-southeast-1-textract-sqs-queue"

# S3 bucket
aws_s3_bucket_name = "182191634518-ap-southeast-1-text-analyzer"

# DynamoDB Table - Document Input
document_input_table_name           = "document-input-dynamodb"
document_input_table_hash_key       = "documentId" # https://www.terraform.io/docs/backends/types/s3.html#dynamodb_table
document_input_table_read_capacity  = "1"
document_input_table_write_capacity = "1"

# DynamoDB Table - Document Output
document_output_table_name           = "document-output-dynamodb"
document_output_table_hash_key       = "documentId" # https://www.terraform.io/docs/backends/types/s3.html#dynamodb_table
document_output_table_read_capacity  = "1"
document_output_table_write_capacity = "1"

# Lambda - doc proc
docproc_function_name = "docproc"
docproc_function_filename= "docproc.zip"
docproc_function_handler = "docproc.lambda_handler"
aws_lambda_function_runtime = "python3.6"

# Lambda service role
lambda_service_role_name = "docproc_service_role"
lambda_service_role_policy_name ="docproc_service_role_policy"

# Lambda SQS Event Source
docproc_event_source_mapping_batch_size = 1

# Textract Lambda archive file
docproc_archive_file_source_file = "src/docproc.py"
docproc_archive_file_output_path = "docproc.zip"

# Lambda Layer Archive File
lambda_layer_archive_file_source_dir = "src/utils/"
lambda_layer_archive_file_output_path = "utils.zip"

# Lambda Layer

lambda_layer_filename = "utils.zip"
lambda_layer_layer_name = "utils"