provider "aws" {
  region = var.aws_region
}

# Custom VPC
resource "aws_vpc" "nginx_vpc" {
  cidr_block           = "10.0.0.0/16" # Adjust CIDR block as needed
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "nginx-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "nginx_pub_subnet" {
  count                   = 1
  vpc_id                  = aws_vpc.nginx_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.nginx_vpc.cidr_block, 8, 0)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "nginx-pub-sub-0${count.index + 1}"
  }
}

# Private Subnets
resource "aws_subnet" "nginx_priv_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.nginx_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.nginx_vpc.cidr_block, 8, count.index + 1)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "nginx-priv-sub-0${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "nginx_igw" {
  vpc_id = aws_vpc.nginx_vpc.id

  tags = {
    Name = "nginx-igw-01"
  }
}

# Public Route Table
resource "aws_route_table" "nginx_route_pub" {
  vpc_id = aws_vpc.nginx_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nginx_igw.id
  }

  tags = {
    Name = "nginx-route-pub-01"
  }
}

resource "aws_route_table_association" "nginx_route_pub_assoc" {
  subnet_id      = aws_subnet.nginx_pub_subnet[0].id
  route_table_id = aws_route_table.nginx_route_pub.id
}

# Elastic IP and NAT Gateway
resource "aws_eip" "nginx_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nginx_nat" {
  allocation_id = aws_eip.nginx_eip.id
  subnet_id     = aws_subnet.nginx_pub_subnet[0].id

  tags = {
    Name = "nginx-nat-01"
  }
}

# Private Route Table
resource "aws_route_table" "nginx_route_priv" {
  vpc_id = aws_vpc.nginx_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nginx_nat.id
  }

  tags = {
    Name = "nginx-route-priv-01"
  }
}

resource "aws_route_table_association" "nginx_route_priv_assoc" {
  count          = length(aws_subnet.nginx_priv_subnet)
  subnet_id      = aws_subnet.nginx_priv_subnet[count.index].id
  route_table_id = aws_route_table.nginx_route_priv.id
}

# Security Groups
resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.nginx_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your IP in production
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "bastion_sg"
  }
}

resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.nginx_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-sg"
  }
}

# Instances
resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.bastion_instance_type
  subnet_id                   = aws_subnet.nginx_pub_subnet[0].id
  key_name                    = var.key_name
  security_groups             = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "bastion-instance"
  }
}

resource "aws_instance" "private_instance" {
  ami                         = var.ami_id
  instance_type               = var.private_instance_type
  subnet_id                   = aws_subnet.nginx_priv_subnet[0].id
  key_name                    = var.key_name
  security_groups             = [aws_security_group.private_sg.id]
  associate_public_ip_address = false

  tags = {
    Name = "private-instance"
  }
}

resource "aws_instance" "private_instance_2" {
  ami                         = var.ami_id
  instance_type               = var.private_instance_type
  subnet_id                   = aws_subnet.nginx_priv_subnet[1].id
  key_name                    = var.key_name
  security_groups             = [aws_security_group.private_sg.id]
  associate_public_ip_address = false

  tags = {
    Name = "private-instance-2"
  }
}
