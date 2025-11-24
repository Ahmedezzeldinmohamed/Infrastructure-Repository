provider "aws" {
  region = "us-east-1"
}

# ---------------------------------------------------------
# 1.(Network)
# ---------------------------------------------------------

# Create New VPC 
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "obelion-vpc" }
}

# (Availability Zones) Allowed
data "aws_availability_zones" "available" {
  state = "available"
}

# Create Internet Gateway to allow the servers to reach the Internet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "obelion-igw" }
}

# (Frontend & Backend)
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags                    = { Name = "public-subnet-1" }
}

# 1 Private subnet (Database- AZ 1)
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags              = { Name = "private-subnet-1" }
}

# 2 Private subnet (Database - AZ 2) - AWS RDS require at least 2 Nets
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags              = { Name = "private-subnet-2" }
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Connect the Nets with the router
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

# ---------------------------------------------------------
# 2.(Security Groups)
# ---------------------------------------------------------

# SG to secure (EC2)
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  # to allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # to allow the privates Ports for Apps (NodeJS/Laravel)
  ingress {
    from_port   = 3000
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # for updates
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SG for (RDS)
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow MySQL from EC2 only"
  vpc_id      = aws_vpc.main.id

  # access granted only for our servers (Security Requirement)
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id] # connect to EC2
  }
}

# ---------------------------------------------------------
# 3.(EC2 Instances)
# ---------------------------------------------------------

# Ubuntu 22.04 
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Backend Machine (Laravel)
resource "aws_instance" "backend" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro" # Free Tier (1 vCPU, 1 GB RAM)
  
  # Key Pair
  key_name      = "obelion-key" 

  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  # 8 GB Disk (Default for AMI, but explicit here)
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  tags = { Name = "Backend-Server" }
}

# Frontend Machine (NodeJS)
resource "aws_instance" "frontend" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro" # Free Tier
  key_name      = "obelion-key"

  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  tags = { Name = "Frontend-Server" }
}

# ---------------------------------------------------------
# 4.(RDS MySQL)
# ---------------------------------------------------------

# Gather all Nets related to the Database
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "main-rds-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = { Name = "My DB Subnet Group" }
}

resource "aws_db_instance" "default" {
  allocated_storage      = 20            # Free Tier Limit
  db_name                = "ecommerce_db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro" # Free Tier Eligible 
  username               = "admin"
  password               = "StrongPass12345" 
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true          
  publicly_accessible    = false         # No Internet Exposure (Task Requirement)
  
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
}

# ---------------------------------------------------------
# 5.(Outputs)
# ---------------------------------------------------------

output "backend_public_ip" {
  value = aws_instance.backend.public_ip
}

output "frontend_public_ip" {
  value = aws_instance.frontend.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}
