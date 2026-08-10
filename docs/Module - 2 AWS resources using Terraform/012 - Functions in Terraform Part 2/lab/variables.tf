variable "environment" {
  default = "dev"
}

variable "instance_type" {
  default = "t2.micro"

  validation {
    condition     = length(var.instance_type) >= 2 && length(var.instance_type) <= 20
    error_message = "instance type must be between 2 and 20 charecters"
  }

  validation {
    condition     = can(regex("^t[2-3]\\.", var.instance_type))
    error_message = "instance type must be t2 or t3"
  }
}

variable "backup_name" {
  default = "daily_backup"

  validation {
    condition     = endswith(var.backup_name, "_backup")
    error_message = "Backup name must be end with _backup"
  }
}

variable "user_location" {
  default = ["us-east-1", "us-west-2", "us-east-1"]
}

variable "default_locations" {
  default = ["us-west-1"]
}

variable "monthly_cost" {
  default = [-50, 100, 75, 200]
}