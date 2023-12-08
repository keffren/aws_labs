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

    count = length(var.public_subnets)

    subnet_id      = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

# SECURITY GROUPS
resource "aws_security_group" "alb" {
    name        = "aws-labs-alb-sg"
    description = "Allow HTTP and HTTPS traffic"
    vpc_id      = aws_vpc.main_vpc.id

    ingress {
        description      = "Allow HTTP requests"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
        description      = "Allow HTTPS requests"
        from_port        = 443
        to_port          = 443
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    tags = {
        Name = "aws-labs-alb-sg"
        Project = "Hands-on-4"
        Terraform = "true"
    }
}

resource "aws_security_group" "apps" {
    name        = "aws-labs-apps-sg"
    description = "Allow traffic from ALB"
    vpc_id      = aws_vpc.main_vpc.id

    ingress {
        description      = "Allow alb HTTPS requests"
        from_port        = 443
        to_port          = 443
        protocol         = "tcp"
        security_groups  = [aws_security_group.alb.id]
    }

    ingress {
        description      = "Allow alb HTTPS requests"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        security_groups  = [aws_security_group.alb.id]
    }

    ingress {
        description      = "Allow traffic from SSH"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    tags = {
        Name = "aws-labs-apps-sg"
        Project = "Hands-on-4"
        Terraform = "true"
    }
}