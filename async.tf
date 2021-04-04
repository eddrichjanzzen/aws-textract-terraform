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
	bucket = aws_s3_bucket.existing_documents.id

	lambda_function {
		lambda_function_arn = aws_lambda_function.s3batchproc.arn
		events              = ["s3:ObjectCreated:*"]
	}

	depends_on = [
		aws_s3_bucket.existing_documents,
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
			ASYNC_QUEUE_URL=aws_sqs_queue.async_queue.id,
			SNS_TOPIC_ARN=aws_sns_topic.job_notification.arn,
			SNS_ROLE_ARN=aws_iam_role.textract_service_role.arn
		}
	}
}

# Check every 5 mins
resource "aws_cloudwatch_event_rule" "rule" {
	name = "every-five-minutes"
	description = "Fires every five minutes"
	schedule_expression = var.asyncproc_cloudwatch_trigger_schedule
}

resource "aws_cloudwatch_event_target" "check_foo_every_five_minutes" {
	rule = aws_cloudwatch_event_rule.rule.name
	target_id = var.asyncproc_function_name
	arn = aws_lambda_function.asyncproc.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
	statement_id = "AllowExecutionFromCloudWatch"
	action = "lambda:InvokeFunction"
	function_name = aws_lambda_function.asyncproc.function_name
	principal = "events.amazonaws.com"
	source_arn = aws_cloudwatch_event_rule.rule.arn
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

# Textract IAM Role and Policy
resource "aws_iam_role" "textract_service_role" {
	name = var.textract_service_role_name
	assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"Service": "textract.amazonaws.com"
			},
			"Action": "sts:AssumeRole"
		}
	]
}
EOF
}

resource "aws_iam_policy" "textract_service_role_policy" {
	name        = var.textract_service_role_policy_name
	description = "Provides access to sns"
	path        = "/"
	policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "",
			"Effect": "Allow",
			"Action": [
				"sns:*"
			],
			"Resource": "*"
		}
	]
}
EOF
}

resource "aws_iam_role_policy_attachment" "textract_policy_attachment" {
	role       = aws_iam_role.textract_service_role.name
	policy_arn = aws_iam_policy.textract_service_role_policy.arn
}