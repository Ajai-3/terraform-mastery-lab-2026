variable "Environment" {
  description = "Project environment"
  type = string
  default = "dev"
}


variable "ec2_config" {
  description = "Configuration settings for the EC2 instance"
  type = object({
    ami           = string
    instance_type = string
    volume_size   = number 
    enable_public = bool
  })

  default = {
    ami           = "ami-0c7217cdde317cfec"
    instance_type = "t3.micro"
    volume_size   = 20
    enable_public = true
  }
}