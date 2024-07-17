
# VPC
resource "aws_vpc" "vpc-2" {
  cidr_block = var.cidr
  tags = {
    Name = "vpc-2"
  }
}

# Subnet
resource "aws_subnet" "subnet-2" {
  vpc_id     = aws_vpc.vpc-2.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc-2.id
  tags = {
    Name = "gw"
  }
}

# Route Table
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.vpc-2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Route Table Association
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.subnet-2.id
  route_table_id = aws_route_table.example.id
}

# Security Group
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc-2.id

  dynamic "ingress" {
    for_each = [22, 80]
    iterator = port
    content {
      description = "Allow traffic on port ${port.value}"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

# Key Pair
resource "aws_key_pair" "demo-ec2-key" {
  key_name   = "demo-key"
  public_key = file("${path.module}/id_rsa.pub")
}

# EC2 Instance
resource "aws_instance" "demo-ec2" {
  ami           = var.ami_value
  instance_type = var.instance_type_value
  key_name      = aws_key_pair.demo-ec2-key.key_name
  subnet_id     = aws_subnet.subnet-2.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]

  tags = {
    Name = "demo-instance"
  }
}


