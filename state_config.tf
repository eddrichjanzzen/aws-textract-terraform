terraform {
  backend "s3" {
    region         = "ap-southeast-1"
    bucket         = "449276385511-ap-southeast-1-terraform-state"
    key            = "aws-ecr-terraform.tfstate"
    encrypt        = "true"
    dynamodb_table = "terraform-state-lock" 
  }
}