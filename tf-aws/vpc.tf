# VPC
resource "aws_vpc" "ecomm" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ecomm"
  }
}

# Web Subnet
resource "aws_subnet" "ecomm-web-sn" {
  vpc_id     = aws_vpc.ecomm.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "ecomm-web-subnet"
  }
}

# API Subnet
resource "aws_subnet" "ecomm-api-sn" {
  vpc_id     = aws_vpc.ecomm.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "ecomm-api-subnet"
  }
}

# Database Subnet
resource "aws_subnet" "ecomm-db-sn" {
  vpc_id     = aws_vpc.ecomm.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "ecomm-db-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ecomm-igw" {
  vpc_id = aws_vpc.ecomm.id

  tags = {
    Name = "ecomm-internet-gateway"
  }
}

# Route Table
resource "aws_route_table" "ecomm-pub-rt" {
  vpc_id = aws_vpc.ecomm.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecomm-igw.id
  }

  tags = {
    Name = "ecomm-public-rt"
  }
}

# Web Subnet Association
resource "aws_route_table_association" "ecomm-web-asc" {
  subnet_id      = aws_subnet.ecomm-web-sn.id
  route_table_id = aws_route_table.ecomm-pub-rt.id
}

# API Subnet Association
resource "aws_route_table_association" "ecomm-api-asc" {
  subnet_id      = aws_subnet.ecomm-api-sn.id
  route_table_id = aws_route_table.ecomm-pub-rt.id
}

# Private Route Table
resource "aws_route_table" "ecomm-pvt-rt" {
  vpc_id = aws_vpc.ecomm.id

  tags = {
    Name = "ecomm-private-rt"
  }
}

# DB Subnet Association
resource "aws_route_table_association" "ecomm-db-asc" {
  subnet_id      = aws_subnet.ecomm-db-sn.id
  route_table_id = aws_route_table.ecomm-pvt-rt.id
}

# NACL
resource "aws_network_acl" "ecomm-nacl" {
  vpc_id = aws_vpc.ecomm.id

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
    Name = "ecomm-nacl"
  }
}

# NACL Associations - Web
resource "aws_network_acl_association" "ecomm-nacl-asc" {
  network_acl_id = aws_network_acl.ecomm-nacl.id
  subnet_id      = aws_subnet.ecomm-web-sn.id
}

# NACL Associations - API
resource "aws_network_acl_association" "ecomm-nacl-asc-api" {
  network_acl_id = aws_network_acl.ecomm-nacl.id
  subnet_id      = aws_subnet.ecomm-api-sn.id
}

# NACL Associations - DB
resource "aws_network_acl_association" "ecomm-nacl-asc-db" {
  network_acl_id = aws_network_acl.ecomm-nacl.id
  subnet_id      = aws_subnet.ecomm-db-sn.id
}

# Web Security Group
resource "aws_security_group" "ecomm-web-sg" {
  name        = "ecomm-web-sg"
  description = "Allow Web Traffic"
  vpc_id      = aws_vpc.ecomm.id

  tags = {
    Name = "ecomm-web-sg"
  }
}

# Web Security Group Ingress Rule - ssh
resource "aws_vpc_security_group_ingress_rule" "ecomm-web-sg-ssh" {
  security_group_id = aws_security_group.ecomm-web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Web Security Group Ingress Rule - http
resource "aws_vpc_security_group_ingress_rule" "ecomm-web-sg-http" {
  security_group_id = aws_security_group.ecomm-web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Web Security Group Egress Rule - All
resource "aws_vpc_security_group_egress_rule" "ecomm-web-sg-all" {
  security_group_id = aws_security_group.ecomm-web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# API Security Group
resource "aws_security_group" "ecomm-api-sg" {
  name        = "ecomm-api-sg"
  description = "Allow API Traffic"
  vpc_id      = aws_vpc.ecomm.id

  tags = {
    Name = "ecomm-api-sg"
  }
}

# API Security Group Ingress Rule - ssh
resource "aws_vpc_security_group_ingress_rule" "ecomm-api-sg-ssh" {
  security_group_id = aws_security_group.ecomm-api-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# API Security Group Ingress Rule - http
resource "aws_vpc_security_group_ingress_rule" "ecomm-api-sg-http" {
  security_group_id = aws_security_group.ecomm-api-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

# API Security Group Egress Rule - All
resource "aws_vpc_security_group_egress_rule" "ecomm-api-sg-all" {
  security_group_id = aws_security_group.ecomm-api-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# DB Security Group
resource "aws_security_group" "ecomm-db-sg" {
  name        = "ecomm-db-sg"
  description = "Allow DB Traffic"
  vpc_id      = aws_vpc.ecomm.id

  tags = {
    Name = "ecomm-db-sg"
  }
}

# DB Security Group Ingress Rule - ssh
resource "aws_vpc_security_group_ingress_rule" "ecomm-db-sg-ssh" {
  security_group_id = aws_security_group.ecomm-db-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# DB Security Group Ingress Rule - postgres
resource "aws_vpc_security_group_ingress_rule" "ecomm-db-sg-postgres" {
  security_group_id = aws_security_group.ecomm-db-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

# DB Security Group Egress Rule - All
resource "aws_vpc_security_group_egress_rule" "ecomm-db-sg-all" {
  security_group_id = aws_security_group.ecomm-db-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# EC2 Web Server
resource "aws_instance" "ecomm-web-server" {
  ami           = "ami-06cff85354b67982b"
  instance_type = "t2.micro"
  key_name      = "2502"
  subnet_id     = aws_subnet.ecomm-web-sn.id
  vpc_security_group_ids = [aws_security_group.ecomm-web-sg.id]
  
  tags = {
    Name = "ecomm-web-server"
  }
}
