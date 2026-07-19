variable "environment_name" {
  type        = string
  description = "Deployment environment (e.g., dev, staging, prod)"
  default     = "dev"
}

variable "s3_bucket_name" {
  type        = string
  description = "Globally unique name for the static website S3 bucket"
  default     = "static-website-dev-002285-n1"
}