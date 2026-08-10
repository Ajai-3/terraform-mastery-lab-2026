
data "aws_vpc" "vpc" {

  filter {
    name   = "tag:Name"
    values = ["default"]
  }
}

data "aws_subnet" "subnet_1" {

  vpc_id = data.aws_vpc.vpc.id

  filter {
    name   = "tag:Name"
    values = ["subnet_1"]
  }
}

data "aws_subnet" "subnet_2" {
  
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name = "tag:Name"
    values = ["subnet_2"]
  }

}

data "aws_ami" "linux2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "subnet_1_instance" {
  count = 2
  ami = data.aws_ami.linux2.id

  instance_type = var.instance_type
  subnet_id     = data.aws_subnet.subnet_1.id

  tags = {
    Name = "Subnet_1_Instance-${count.index + 1}"
  }
}

resource "aws_instance" "subnet_2_instance" {
  count = 2
  ami = data.aws_ami.linux2.id

  instance_type = var.instance_type
  subnet_id = data.aws_subnet.subnet_2.id

  tags = {
    Name = "Subnet_2_Instance-${count.index + 1}"
  }
   
}
