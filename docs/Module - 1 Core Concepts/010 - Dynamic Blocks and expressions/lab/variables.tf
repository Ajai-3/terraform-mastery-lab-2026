variable "Environment" {
  description = "Project environment"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "The AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}


variable "ec2_config" {
  description = "Configuration settings for the EC2 instance"
  type = object({
    ami                = string
    instance_type_dev  = string
    instance_type_prod = string
  })

  default = {
    ami                = "ami-0c7217cdde317cfec"
    instance_type_dev  = "t2.micro"
    instance_type_prod = "t3.micro"
  }
}

variable "ingress_rules" {
  description = "List if ingress rules for security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks  = list(string)
    description = string
  }))

  default = [{
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
    description = "HTTP"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks  = ["0.0.0.0/0"]
      description = "HTTPS"
    }
  ]
}