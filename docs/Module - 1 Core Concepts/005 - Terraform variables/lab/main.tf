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

provider "aws" {
  region = "us-east-1"
}

variable "Environment" {
  description = "The deployment environment (e.g., dev, stage, prod) to avoid hardcoding names across resources."
  default = "dev"
  type = string
}

locals {
  bucket_name = "my-app-storage-${var.Environment}-999101"
  vpc_name = "${var.Environment}-vpc"
}

output "vpc_id" {
  value = aws_vpc.main.id
}

resource "aws_s3_bucket" "app_bucket" {
  # Resulting bucket name: "my-app-storage-dev-999101"
  bucket = local.bucket_name

  tags = {
    Environment = var.Environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    # Dynamically sets name to "dev-vpc"
    Name        = local.vpc_name
    Environment = var.Environment
    ManagedBy   = "Terraform"
  }
}