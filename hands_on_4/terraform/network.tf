# VPC
resource "aws_vpc" "main_vpc" {
    cidr_block       = var.vpc_cidr_block

    tags = {
        Name = "aws-labs"
        Project = "Hands-on-4"
        Terraform = "true"
    }
}

resource "aws_internet_gateway" "main_igw" {
    vpc_id = aws_vpc.main_vpc.id

    tags = {
        Name = "aws-labs-igw"
        Project = "Hands-on-4"
        Terraform = "true"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main_igw.id
    }

    tags = {
        Name = "aws-labs-public-rt"
        Project = "Hands-on-4"
        Terraform = "true"
    }
}

# SUBNETs
resource "aws_subnet" "public" {
    vpc_id                  = aws_vpc.main_vpc.id

    count = length(var.public_subnets)

    cidr_block              = var.public_subnets[count.index]
    availability_zone       = count.index == 0 ? "eu-west-1a" : "eu-west-1c"

    tags = {
        Name = "public-${count.index}"
        Project = "Hands-on-4"
        Terraform = "true"
    }
}

resource "aws_route_table_association" "allow_internet_access" {

    count = length(var.private_subnets)

    subnet_id      = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
    vpc_id                  = aws_vpc.main_vpc.id

    count = length(var.private_subnets)

    cidr_block              = var.private_subnets[count.index]
    availability_zone       = count.index == 0 ? "eu-west-1a" : "eu-west-1c"

    tags = {
        Name = "private-${count.index}"
        Project = "Hands-on-4"
        Terraform = "true"
    }
}
