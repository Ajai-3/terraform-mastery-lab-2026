resource "aws_s3_bucket" "app_bucket" {
  # Resulting bucket name: "my-app-storage-dev-999101"
  bucket = local.bucket_name

  tags = {
    Environment = var.Environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    # Dynamically sets name to "dev-vpc"
    Name        = local.vpc_name
    Environment = var.Environment
    ManagedBy   = "Terraform"
  }
}