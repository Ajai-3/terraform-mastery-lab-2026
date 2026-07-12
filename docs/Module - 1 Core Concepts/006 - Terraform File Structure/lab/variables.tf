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

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}