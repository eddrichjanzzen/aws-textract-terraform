# AWS SQS Queue
resource "aws_sqs_queue" "this" {
  name                  = var.aws_sqs_queue_name
}

# AWS SQS Queue policy
resource "aws_sqs_queue_policy" "this" {
  queue_url             =  aws_sqs_queue.this.id
  policy                = <<POLICY
{
  "Version" : "2012-10-17",
  "Id" : "sqspolicy",
  "Statement" : [
    {
      "Sid" : "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.this.arn}",
      "Condition" : {
        "ArnEquals": { 
          "aws:SourceArn": "${aws_s3_bucket.this.arn}"
        }
      }
    }
  ]   
}
POLICY
}


# AWS S3 bucket
resource "aws_s3_bucket" "this" {
  bucket = var.aws_s3_bucket_name
}

# AWS S3 bucket notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.this.id

  queue { 
    queue_arn = aws_sqs_queue.this.arn
    events = ["s3:ObjectCreated:Put"]
  }

}

# DynamoDB Table
resource "aws_dynamodb_table" "this" {
  name           = var.aws_dynamodb_table_name
  hash_key       = var.aws_dynamodb_table_hash_key
  read_capacity  = var.aws_dynamodb_table_read_capacity
  write_capacity = var.aws_dynamodb_table_write_capacity

  attribute {
    name = var.aws_dynamodb_table_hash_key
    type = "S"
  }

}