# General
aws_region  = "ap-southeast-1"
aws_account = "182101634518"
namespace   = "shared"
environment = "production"
aws_role    = "OrganizationAccountAccessRole"
aws_textract_repository_name ="project-textract-service"
bounded_context = "shared"

# SQS - Sync Queue
sync_queue_name = "sync-queue"
sync_queue_visibility_timeout = 14400

# SQS - Async Queue
async_queue_name = "async-queue"
async_queue_visibility_timeout = 14400

# SQS - Async Complete Queue
async_complete_queue_name = "async-complete-queue"
async_complete_queue_visibility_timeout = 14400

# SNS Job notifications Topic
job_notification_topic_name = "job-notifications-sns"

# New Documents S3 bucket
new_documents_bucket_name = "182191634518-ap-southeast-1-new-documents"

# Textract Results S3 bucket
textract_results_bucket_name = "182191634518-ap-southeast-1-textract-results"

# Existing documents S3 bucket
existing_documents_bucket_name = "182191634518-ap-southeast-1-existing-documents"

# General Function runtime
aws_lambda_function_runtime = "python3.6"

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

# S3proc - Lambda
s3proc_function_name = "s3proc"
s3proc_function_filename= "zipfiles/s3proc.zip"
s3proc_function_handler = "s3proc.lambda_handler"
s3proc_archive_file_source_file = "src/s3proc.py"
s3proc_archive_file_output_path = "zipfiles/s3proc.zip"

# Docproc - Lambda
docproc_function_name = "docproc"
docproc_function_filename= "zipfiles/docproc.zip"
docproc_function_handler = "docproc.lambda_handler"
docproc_archive_file_source_file = "src/docproc.py"
docproc_archive_file_output_path = "zipfiles/docproc.zip"

# Syncproc - Lambda
syncproc_function_name = "syncproc"
syncproc_function_filename= "zipfiles/syncproc.zip"
syncproc_function_handler = "syncproc.lambda_handler"
syncproc_function_timeout = 600
syncproc_archive_file_source_file = "src/syncproc.py"
syncproc_archive_file_output_path = "zipfiles/syncproc.zip"
syncproc_event_source_mapping_batch_size = 1

# S3batchproc - Lambda
s3batchproc_function_name = "s3batchproc"
s3batchproc_function_filename= "zipfiles/s3batchproc.zip"
s3batchproc_function_handler = "s3batchproc.lambda_handler"
s3batchproc_archive_file_source_file = "src/s3batchproc.py"
s3batchproc_archive_file_output_path = "zipfiles/s3batchproc.zip"

# Jobresultsproc - Lambda
jobresultsproc_function_name = "jobresultsproc"
jobresultsproc_function_filename= "zipfiles/jobresultsproc.zip"
jobresultsproc_function_handler = "jobresultsproc.lambda_handler"
jobresultsproc_function_timeout = 600
jobresultsproc_archive_file_source_file = "src/jobresultsproc.py"
jobresultsproc_archive_file_output_path = "zipfiles/jobresultsproc.zip"
jobresultsproc_event_source_mapping_batch_size = 1


# Asyncproc - Lambda
asyncproc_function_name = "asyncproc"
asyncproc_function_filename= "zipfiles/asyncproc.zip"
asyncproc_function_handler = "asyncproc.lambda_handler"
asyncproc_function_timeout = 600
asyncproc_cloudwatch_trigger_schedule = "rate(5 minutes)"
asyncproc_archive_file_source_file = "src/asyncproc.py"
asyncproc_archive_file_output_path = "zipfiles/asyncproc.zip"

# Lambda SQS Event Source

# Lambda service role
lambda_service_role_name = "aws_lambda_service_role"
lambda_service_role_policy_name ="aws_lambda_service_role_policy"

# Textract service role
textract_service_role_name = "aws_textract_service_role"
textract_service_role_policy_name ="aws_textract_service_role_policy"

# Lambda Layer Archive File
lambda_layer_archive_file_source_dir = "src/utils/"
lambda_layer_archive_file_output_path = "zipfiles/utils.zip"

# Lambda Layer

lambda_layer_filename = "zipfiles/utils.zip"
lambda_layer_layer_name = "utils"