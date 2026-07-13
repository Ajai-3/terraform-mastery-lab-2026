variable "Environment" {
  description = "The deployment environment (e.g., dev, stage, prod) to avoid hardcoding names across resources."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "bucket_count" {
  description = "Count of the bucket"
  type = number
  default = 1
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type = list(string)
  default = ["10.0.0.0/16", "172.16.0.0/16", "192.168.0.0/16"]
}


variable "vpc_cidr_by_set" {
  description = "The CIDR block for the VPC."
  type = set(string)
  default = ["10.0.0.0/16", "172.16.0.0/16", "192.168.0.0/16"]
}

variable "vpc_cidr_by_env" {
  description = "CIDR block mapped by environment"
  type        = map(string)
  default     = {
    dev   = "10.0.0.0/16"
    stage = "10.1.0.0/16"
    prod  = "10.2.0.0/16"
  }
}



variable "ec2_config" {
  description = "Tuple containing: [ami_id, instance_type, disk_size_gb, enable_public_ip]"
  type        = tuple([string, string, number, bool])
  default     = ["ami-0c7217cdde317cfec", "t3.micro", 20, true]
}

variable "ec2_config_object" {
  description = "Object containing EC2 instance configurations"
  type = object({
    ami_id           = string
    instance_type   = string
    disk_size_gb     = number
    enable_public_ip = bool
  })
  default = {
    ami_id           = "ami-0c7217cdde317cfec"
    instance_type   = "t3.micro"
    disk_size_gb     = 20
    enable_public_ip = true
  }
}