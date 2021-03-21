terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  assume_role {
    session_name = "terraform"
    role_arn     = "arn:aws:iam::${var.aws_account}:role/${var.aws_role}"
  }  
}
