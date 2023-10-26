# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block       = "10.0.0.0/16"

  # instance_tenancy -  A tenancy option for instances launched into the VPC.
  instance_tenancy = "default"

  tags = {
    Name = "main"
    Terraform = "true"
    Environment = "dev"
    LabNumber= "1"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-igw"
    Terraform = "true"
    Environment = "dev"
    LabNumber= "1"
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
    Environment = "dev"
    LabNumber= "1"
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
    Environment = "dev"
    LabNumber= "1"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# SECURITY GROUPS
resource "aws_security_group" "elb" {
  name        = "app-load-balancer-sg"
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
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "main-alb"
    Terraform = "true"
    Environment = "dev"
    LabNumber= "1"
  }
}

resource "aws_security_group" "tomcat_app" {
  name        = "tomcat-app-sg"
  description = "Allow traffic from ALB and SSH"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description      = "Allow traffic from ELB"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    security_groups = [ aws_security_group.elb.id ]
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
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "tomcat-app-sg"
    Terraform = "true"
    Environment = "dev"
    LabNumber= "1"
  }
}

resource "aws_security_group" "backend" {
  name        = "backend-sg"
  description = "Security group for Backend Services"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description      = "Allow MYSQL-AURORA traffic"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups = [ aws_security_group.tomcat_app.id ]
  }

  ingress {
    description      = "Allow tomcat to connect memcache"
    from_port        = 11211
    to_port          = 11211
    protocol         = "tcp"
    security_groups = [ aws_security_group.tomcat_app.id ]
  }

  ingress {
    description      = "Allow tomcat to connect RabbitMQ"
    from_port        = 5672
    to_port          = 5672
    protocol         = "tcp"
    security_groups = [ aws_security_group.tomcat_app.id ]
  }

  ingress {
    description      = "Allow traffic from SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow all intern traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    self = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "backend-sg"
    Terraform = "true"
    Environment = "dev"
    LabNumber= "1"
  }
}

