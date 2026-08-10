resource "aws_instance" "example" {
  ami = var.ec2_config.ami

  instance_type = var.Environment == "dev" ? var.ec2_config.instance_type_dev : var.ec2_config.instance_type_prod

  tags = {
    Name = "EC2-Instance"
  }

}

resource "aws_security_group" "ingress_rules" {
  name = "sg"

  dynamic "ingress" {
    for_each = var.ingress_rules

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      cidr_blocks = ingress.value.cidr_blocks
      protocol    = ingress.value.protocol
    }
  }
  egress = []
}


locals {
  all_instance_ids = aws_instance.example[*].id
}

output "instances" {
  value = local.all_instance_ids
}