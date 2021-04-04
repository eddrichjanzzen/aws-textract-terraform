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

