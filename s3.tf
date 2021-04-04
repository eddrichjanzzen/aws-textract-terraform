# random string generator
resource "random_string" "id" {
  length = 5
  special = false
  upper = false
}

# S3 Bucket for new Documents
resource "aws_s3_bucket" "new_documents" {
  bucket = "${var.new_documents_bucket_name}-${random_string.id.result}"
  force_destroy = true
}

# S3 Bucket for new Documents Policy
resource "aws_s3_bucket_policy" "new_documents" {
  bucket                = aws_s3_bucket.new_documents.id
  policy                = <<POLICY
{
  "Version" : "2012-10-17",
  "Id" : "",
  "Statement" : [
    {
      "Sid" : "First",
      "Effect": "Allow",
      "Action": "s3:*",
      "Principal": {
        "AWS": "${aws_iam_role.lambda_service_role.arn}"
      },
      "Resource": [
        "${aws_s3_bucket.new_documents.arn}"
      ]
    }
  ]   
}
POLICY
}


# S3 Bucket for Textract Results
resource "aws_s3_bucket" "textract_results" {
  bucket = "${var.textract_results_bucket_name}-${random_string.id.result}"
  force_destroy = true
}

# S3 Bucket Policy
resource "aws_s3_bucket_policy" "textract_results" {
  bucket                = aws_s3_bucket.textract_results.id
  policy                = <<POLICY
{
  "Version" : "2012-10-17",
  "Id" : "",
  "Statement" : [
    {
      "Sid" : "First",
      "Effect": "Allow",
      "Action": "s3:*",
      "Principal": {
        "AWS": "${aws_iam_role.lambda_service_role.arn}"
      },
      "Resource": [
        "${aws_s3_bucket.textract_results.arn}"
      ]
    }
  ]   
}
POLICY
}


# S3 Bucket for Existing Documents
resource "aws_s3_bucket" "existing_documents" {
  bucket = "${var.existing_documents_bucket_name}-${random_string.id.result}"
  force_destroy = true
}

# S3 Bucket Policy
resource "aws_s3_bucket_policy" "existing_documents" {
  bucket                = aws_s3_bucket.existing_documents.id
  policy                = <<POLICY
{
  "Version" : "2012-10-17",
  "Id" : "",
  "Statement" : [
    {
      "Sid" : "First",
      "Effect": "Allow",
      "Action": "s3:*",
      "Principal": {
        "AWS": "${aws_iam_role.lambda_service_role.arn}"
      },
      "Resource": [
        "${aws_s3_bucket.existing_documents.arn}"
      ]
    }
  ]   
}
POLICY
}
