variable "environment" {
 default = "dev"
}

variable "project_name" {
  type    = string
  default = "Project XYZ Resource"
}

variable "default_tags" {
  default = {
    company    = "XYZ"
    managed_by = "terraform"
  }
}

variable "environment_tags" {
  default = {
    environment = "production"
    cost_center = "cc-123"
  }
}

variable "bucket_name" {
  default = "project alfa bucket with CAPS and spaces!!!"
}

variable "allowed_ports" {
  default = "80, 443, 8080, 3306"
}

variable "instance_size" {
  default = {
    dev = "t2.micro"
    staging = "t3.small"
    prod = "t3.large"
  }
}