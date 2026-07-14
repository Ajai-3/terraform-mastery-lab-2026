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

variable "bucket_names_list" {
  description = "List of S3 bucket names to create"
  type        = list(string)
  default     = ["my-app-storage-9991011", "my-app-storage-9992022"]
}


variable "bucket_names_set" {
  description = "Set of S3 bucket names to create"
  type        = set(string)
  default     = ["my-app-storage-99910111", "my-app-storage-99920222"]
}

variable "bucket_names_map" {
  description = "Map of S3 bucket name to create"
  type = map(string)

  default = {
    "bucket_1" = "my-app-storage-999101111",
    "bucket_2" = "my-app-storage-999202222"
  }
}