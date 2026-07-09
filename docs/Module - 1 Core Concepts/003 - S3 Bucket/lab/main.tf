terraform {
   required_providers {
     aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
     }
   }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}


# Create s3 bucket

// "first_bucket" this is the local name of the bucket (you cannot reuse the local name)
resource "aws_s3_bucket" "first_bucket" {
  bucket = "my-tf-test-bucket-99901" // bucket name must be unique

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}