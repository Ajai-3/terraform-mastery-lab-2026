resource "aws_s3_bucket" "app_bucket" {
  # Resulting bucket name: "my-app-storage-dev-999101"
  bucket = local.bucket_name

  count  = var.bucket_count

  tags = {
    Environment = var.Environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc" "main" {
  # list of string
  cidr_block           = var.vpc_cidr[0]

  # map
  # cidr_block        = var.vpc_cidr_by_env.dev

  # set of string - no duplicate value allowed
  # cidr_block        = tolist(var.vpc_cidr_by_set[0])


  enable_dns_hostnames = true

  tags = {
    # Dynamically sets name to "dev-vpc"
    Name        = local.vpc_name
    Environment = var.Environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_instance" "example" {
  ami                         = var.ec2_config[0] # "ami-0c55b159cbfafe1f0" (string)
  instance_type               = var.ec2_config[1] # "t2.micro" (string)
  associate_public_ip_address = var.ec2_config[3] # true (bool)

  root_block_device {
    volume_size = var.ec2_config[2]               # 20 (number)
  }

  tags = {
    Name = "Tuple-Configured-EC2"
  }
}