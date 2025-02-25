# VPC
resource "aws_vpc" "lms" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "lms"
  }
}

# Web Subnet
resource "aws_subnet" "lms-web-sn" {
  vpc_id     = aws_vpc.lms.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "lms-web-subnet"
  }
}

# API Subnet
resource "aws_subnet" "lms-api-sn" {
  vpc_id     = aws_vpc.lms.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "lms-api-subnet"
  }
}

# Database Subnet
resource "aws_subnet" "lms-db-sn" {
  vpc_id     = aws_vpc.lms.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "lms-db-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "lms-igw" {
  vpc_id = aws_vpc.lms.id

  tags = {
    Name = "lms-internet-gateway"
  }
}

# Route Table
resource "aws_route_table" "lms-pub-rt" {
  vpc_id = aws_vpc.lms.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lms-igw.id
  }

  tags = {
    Name = "lms-public-rt"
  }
}

# Web Subnet Association
resource "aws_route_table_association" "lms-web-asc" {
  subnet_id      = aws_subnet.lms-web-sn.id
  route_table_id = aws_route_table.lms-pub-rt.id
}

# API Subnet Association
resource "aws_route_table_association" "lms-api-asc" {
  subnet_id      = aws_subnet.lms-api-sn.id
  route_table_id = aws_route_table.lms-pub-rt.id
}
