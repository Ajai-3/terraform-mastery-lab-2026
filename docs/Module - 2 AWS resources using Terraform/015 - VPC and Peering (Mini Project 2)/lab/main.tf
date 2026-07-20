# ==============================================================================
# 1. VPC CONFIGURATION
# ==============================================================================

resource "aws_vpc" "primary_vpc" {
  provider   = aws.primary
  cidr_block = var.primary_vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Primary-VPC-${var.primary}"
  }
}

resource "aws_vpc" "secondary_vpc" {
  provider   = aws.secondary
  cidr_block = var.secondary_vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Secondary-VPC-${var.secondary}"
  }
}

# ==============================================================================
# 2. SUBNET CONFIGURATION
# ==============================================================================

resource "aws_subnet" "primary_subnet" {
  provider                = aws.primary
  vpc_id                  = aws_vpc.primary_vpc.id
  cidr_block              = var.primary_subnet_cidr
  availability_zone       = data.aws_availability_zones.primary.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "Primary-VPC-subnet-${var.primary}"
    Environment = var.environment
  }
}

resource "aws_subnet" "secondary_subnet" {
  provider                = aws.secondary
  vpc_id                  = aws_vpc.secondary_vpc.id
  cidr_block              = var.secondary_subnet_cidr
  availability_zone       = data.aws_availability_zones.secondary.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "Secondary-VPC-subnet-${var.secondary}"
    Environment = var.environment
  }
}

# ==============================================================================
# 3. INTERNET GATEWAYS & ROUTING
# ==============================================================================

resource "aws_internet_gateway" "primary-gw" {
  provider = aws.primary
  vpc_id   = aws_vpc.primary_vpc.id

  tags = {
    Name        = "Primary-IGW-${var.primary}"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "secondary-gw" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary_vpc.id

  tags = {
    Name        = "Secondary-IGW-${var.secondary}"
    Environment = var.environment
  }
}

resource "aws_route_table" "primary_route_table" {
  provider = aws.primary
  vpc_id   = aws_vpc.primary_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary-gw.id
  }

  tags = {
    Name        = "Primary-Route-Table-${var.primary}"
    Environment = var.environment
  }
}

resource "aws_route_table" "secondary_route_table" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary-gw.id
  }

  tags = {
    Name        = "Secondary-Route-Table-${var.secondary}"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "primary_rta" {
  provider       = aws.primary
  subnet_id      = aws_subnet.primary_subnet.id
  route_table_id = aws_route_table.primary_route_table.id
}

resource "aws_route_table_association" "secondary_rta" {
  provider       = aws.secondary
  subnet_id      = aws_subnet.secondary_subnet.id
  route_table_id = aws_route_table.secondary_route_table.id
}

# ==============================================================================
# 4. VPC PEERING ROUTES
# ==============================================================================

resource "aws_route" "primary_r" {
  provider                  = aws.primary
  route_table_id            = aws_route_table.primary_route_table.id
  destination_cidr_block    = var.secondary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id
}

resource "aws_route" "secondary_r" {
  provider                  = aws.secondary
  route_table_id            = aws_route_table.secondary_route_table.id
  destination_cidr_block    = var.primary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id

  depends_on = [aws_vpc_peering_connection_accepter.secondary_accepter]
}

# ==============================================================================
# 5. SECURITY GROUPS
# ==============================================================================

resource "aws_security_group" "primary_sg" {
  provider    = aws.primary
  name        = "primary-vpc-sg"
  description = "Security group for Primary VPC instance"
  vpc_id      = aws_vpc.primary_vpc.id

  dynamic "ingress" {
    for_each = var.primary_ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks # Fixed typo: changed 'vlaue' to 'value'
    }
  }

  egress {
    description = var.egress_rule.description
    from_port   = var.egress_rule.from_port
    to_port     = var.egress_rule.to_port
    protocol    = var.egress_rule.protocol
    cidr_blocks = var.egress_rule.cidr_blocks
  }

  tags = {
    Name        = "Primary-VPC-SG"
    Environment = var.environment
  }
}

resource "aws_security_group" "secondary_sg" {
  provider    = aws.secondary
  name        = "secondary-vpc-sg"
  description = "Security group for Secondary VPC instance"
  vpc_id      = aws_vpc.secondary_vpc.id

  dynamic "ingress" {
    for_each = var.secondary_ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    description = var.egress_rule.description
    from_port   = var.egress_rule.from_port
    to_port     = var.egress_rule.to_port
    protocol    = var.egress_rule.protocol
    cidr_blocks = var.egress_rule.cidr_blocks
  }

  tags = {
    Name        = "Secondary-VPC-SG"
    Environment = var.environment
  }
}

# ==============================================================================
# 6. COMPUTE (EC2 INSTANCES)
# ==============================================================================

resource "aws_instance" "primary_instance" {
  provider               = aws.primary
  ami                    = data.aws_ami.primary_ami.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.primary_subnet.id
  vpc_security_group_ids = [aws_security_group.primary_sg.id]
  key_name               = var.primary_key_name

  user_data = local.primary_user_data

  tags = {
    Name        = "Primary-EC2"
    Environment = var.environment
  }
}

resource "aws_instance" "secondary_instance" {
  provider               = aws.secondary
  ami                    = data.aws_ami.secondary_ami.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.secondary_subnet.id
  vpc_security_group_ids = [aws_security_group.secondary_sg.id]
  key_name               = var.secondary_key_name

  user_data = local.secondary_user_data

  tags = {
    Name        = "Secondary-EC2"
    Environment = var.environment
  }
}

# ==============================================================================
# 7. VPC PEERING
# ==============================================================================

resource "aws_vpc_peering_connection" "primary_to_secondary" {
  provider    = aws.primary
  peer_region = var.secondary
  vpc_id      = aws_vpc.primary_vpc.id
  peer_vpc_id = aws_vpc.secondary_vpc.id
  auto_accept = false

  tags = {
    Name        = "Primary-to-Secondary-VPC-Peering-Requester"
    Environment = var.environment
  }
}

resource "aws_vpc_peering_connection_accepter" "secondary_accepter" {
  provider                  = aws.secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id
  auto_accept               = true

  tags = {
    Name        = "Primary-to-Secondary-VPC-Peering-Accepter"
    Environment = var.environment
  }
}