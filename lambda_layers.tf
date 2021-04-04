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