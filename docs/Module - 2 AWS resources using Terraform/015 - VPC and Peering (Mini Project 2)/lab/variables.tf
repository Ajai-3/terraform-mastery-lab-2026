variable "environment" {
  type        = string
  description = "The target deployment environment (e.g., dev, staging, prod)."
  default     = "dev"
}

variable "primary" {
  type        = string
  description = "The primary AWS region where the main infrastructure resources will be deployed."
  default     = "us-east-1"
}

variable "secondary" {
  type        = string
  description = "The secondary AWS region used for cross-region peering, failover, or secondary resources."
  default     = "us-west-2"
}

variable "primary_vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "secondary_vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "primary_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "secondary_subnet_cidr" {
  type    = string
  default = "10.1.1.0/24"
}

variable "instance_type" {
  type        = string
  description = "AWS instence type"
  default     = "t3.micro"
}

variable "primary_key_name" {
  type        = string
  description = "Name of the SHH key pair for Primary VPC instance"
  default     = ""
}

variable "secondary_key_name" {
  type        = string
  description = "Name of the SHH key pair for Secondary VPC instance"
  default     = ""
}


variable "primary_ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      description = "SSH from anywhere"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "ICMP from Secondary VPC"
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = ["10.1.0.0/16"] // secondary_vpc_cidr hard coded the value here 
    },
    {
      description = "All traffic from Secondary VPC"
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["10.1.0.0/16"] // secondary_vpc_cidr hard coded the value here 
    }
  ]
}

variable "secondary_ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      description = "SSH from anywhere"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "ICMP from Primary VPC"
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = ["10.0.0.0/16"] // primary_vpc_cidr hard coded the value here 
    },
    {
      description = "All traffic from Primary VPC"
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"] // primary_vpc_cidr hard coded the value here 
    }
  ]
}

variable "egress_rule" {
  type = object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  })
  default = {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}