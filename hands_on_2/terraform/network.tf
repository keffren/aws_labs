# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block       = "10.0.0.0/16"

  # instance_tenancy -  A tenancy option for instances launched into the VPC.
  instance_tenancy = "default"

  tags = {
    Name = "main"
    Terraform = "true"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-igw"
    Terraform = "true"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "main"
    Terraform = "true"
  }
}

# SUBNET
resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"

  tags = {
    Name = "main"
    Terraform = "true"
  }
}

