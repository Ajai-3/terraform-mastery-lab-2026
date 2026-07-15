resource "aws_instance" "example" {
  ami                         = var.ec2_config.ami
  instance_type               = var.ec2_config.instance_type
  associate_public_ip_address = var.ec2_config.enable_public 

  root_block_device {
    volume_size = var.ec2_config.volume_size
  }

  tags = {
    Name = "EC2-Instance"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket" "permanent_bucket" {
  bucket = "prevent-delete-bucket-0028392"

  tags = {
    Description = "This bucket is protected against accidental deletion"
    Environment = "prod"
    ManagedBy   = "Terraform"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_launch_template" "app" {
  name_prefix = "app-templete-"
  image_id = var.ec2_config.ami
  instance_type = var.ec2_config.instance_type

  tags = {
    Environment = var.Environment
    ManagedBy = "Terraform"
  }
}

resource "aws_autoscaling_group" "app_servers" {
  name             = "app-servers-asg"
  desired_capacity = 1
  min_size         = 1 
  max_size         = 5

  availability_zones = ["us-east-1a", "us-east-1b"]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

    lifecycle {
    ignore_changes = [
      desired_capacity,  # Ignore capacity changes by auto-scaling
      load_balancers,    # Ignore if added externally
    ]
  }

  tag {
    key                 = "Environment"
    value               = var.Environment
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "Terraform"
    propagate_at_launch = true
  }
}


resource "aws_security_group" "app_sg" {
  name        = "app-security-group"
  description = "Security group for application servers"

  ingress {
    description = "Allow inbound HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow inbound HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "app-security-group"
    Environment = var.Environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_instance" "app_with_sg" {
  ami           = var.ec2_config.ami
  instance_type = var.ec2_config.instance_type
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  lifecycle {
    replace_triggered_by = [
      aws_security_group.app_sg.id  # Replace instance when SG changes
    ]
  }
}

resource "aws_s3_bucket" "compliance_bucket" {
  bucket = "compliance-bucket"

  tags = {
    Environment = var.Environment
    Compliance  = "SOC2"
  }

  lifecycle {
    postcondition {
      condition     = contains(keys(self.tags), "Compliance")
      error_message = "ERROR: Bucket must have a 'Compliance' tag!"
    }

    postcondition {
      condition     = contains(keys(self.tags), "Environment")
      error_message = "ERROR: Bucket must have an 'Environment' tag!"
    }
  }
}