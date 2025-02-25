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

# Private Route Table
resource "aws_route_table" "lms-pvt-rt" {
  vpc_id = aws_vpc.lms.id

  tags = {
    Name = "lms-private-rt"
  }
}

# DB Subnet Association
resource "aws_route_table_association" "lms-db-asc" {
  subnet_id      = aws_subnet.lms-db-sn.id
  route_table_id = aws_route_table.lms-pvt-rt.id
}

# NACL
resource "aws_network_acl" "lms-nacl" {
  vpc_id = aws_vpc.lms.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "lms-nacl"
  }
}

# NACL Associations - Web
resource "aws_network_acl_association" "lms-nacl-asc" {
  network_acl_id = aws_network_acl.lms-nacl.id
  subnet_id      = aws_subnet.lms-web-sn.id
}

# NACL Associations - API
resource "aws_network_acl_association" "lms-nacl-asc-api" {
  network_acl_id = aws_network_acl.lms-nacl.id
  subnet_id      = aws_subnet.lms-api-sn.id
}

# NACL Associations - DB
resource "aws_network_acl_association" "lms-nacl-asc-db" {
  network_acl_id = aws_network_acl.lms-nacl.id
  subnet_id      = aws_subnet.lms-db-sn.id
}

# Web Security Group
resource "aws_security_group" "lms-web-sg" {
  name        = "lms-web-sg"
  description = "Allow Web Traffic"
  vpc_id      = aws_vpc.lms.id

  tags = {
    Name = "lms-web-sg"
  }
}

# Web Security Group Ingress Rule - ssh
resource "aws_vpc_security_group_ingress_rule" "lms-web-sg-ssh" {
  security_group_id = aws_security_group.lms-web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Web Security Group Ingress Rule - http
resource "aws_vpc_security_group_ingress_rule" "lms-web-sg-http" {
  security_group_id = aws_security_group.lms-web-sg.id
  cidr_ipv6         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Web Security Group Egress Rule - All
resource "aws_vpc_security_group_egress_rule" "lms-web-sg-all" {
  security_group_id = aws_security_group.lms-web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
