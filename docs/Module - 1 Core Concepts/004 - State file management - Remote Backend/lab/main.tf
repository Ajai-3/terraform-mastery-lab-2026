terraform {
    backend "s3" {
      bucket = "my-first-terraform-backend-bucket"
      key = "dev/terrrafrom.tfstate"
      region = "us-east-1"
      encrypt = "true"
      use_lockfile = "true"
    }
    
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "first_bucket" {
  bucket = "my-tf-test-bucket-99901" 

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}