locals {
  CentOS-Stream-9-AMI = "ami-009f51225716cb42f"
  amazon-linux-2023 = "ami-046a9f26a7f14326b"
  ubuntu-ami = "ami-0694d931cee176e7d"
}

#BACKEND INSTANCES
/*
resource "aws_instance" "mysql_db_backend" {
    ami           = local.CentOS-Stream-9-AMI
    instance_type = "t2.micro"
    key_name      = "admin-dev-aws"

    subnet_id   = aws_subnet.main_subnet.id
    private_ip = "10.0.1.100"
    #associate_public_ip_address = true
    security_groups = [ aws_security_group.backend.id ]

    user_data = file("../resources/db_instance_bootstrapping.sh")

    tags = {
        Name = "MYSQL DB Instance"
        Terraform = "true"
        Environment = "dev"
        LabNumber= "1"
    }
}

resource "aws_instance" "tomcat_memcache" {
    ami           = local.CentOS-Stream-9-AMI
    instance_type = "t2.micro"
    key_name      = "admin-dev-aws"

    subnet_id   = aws_subnet.main_subnet.id
    private_ip = "10.0.1.101"
    #associate_public_ip_address = true
    security_groups = [ aws_security_group.backend.id ]

    user_data = file("../resources/memcache_bootstrapping.sh")

    tags = {
        Name = "TomCat MemCache"
        Terraform = "true"
        Environment = "dev"
        LabNumber= "1"
    }
}

resource "aws_instance" "rabbitmq" {
    ami           = local.CentOS-Stream-9-AMI
    instance_type = "t2.micro"
    key_name      = "admin-dev-aws"

    subnet_id   = aws_subnet.main_subnet.id
    private_ip = "10.0.1.102"
    #associate_public_ip_address = true
    security_groups = [ aws_security_group.backend.id ]

    user_data = file("../resources/rabbitmq_bootstrapping.sh")

    tags = {
        Name = "RabbitMQ"
        Terraform = "true"
        Environment = "dev"
        LabNumber= "1"
    }
}
*/

# TOMCAT APP
resource "aws_instance" "app" {
    ami           = local.ubuntu-ami
    instance_type = "t2.micro"
    key_name      = "admin-dev-aws"

    subnet_id   = aws_subnet.main_subnet.id
    private_ip = "10.0.1.103"
    associate_public_ip_address = true
    security_groups = [ aws_security_group.tomcat_app.id ]

    iam_instance_profile = aws_iam_instance_profile.tomcatApp_profile.name

    user_data = <<EOF
#!/bin/bash
sudo apt update
sudo apt upgrade -y
sudo apt install openjdk-11-jdk -y
sudo apt install tomcat9 tomcat9-admin tomcat9-docs tomcat9-common git -y

EOF

    tags = {
        Name = "TomCat App"
        Terraform = "true"
        Environment = "dev"
        LabNumber= "1"
    }
}

resource "aws_iam_instance_profile" "tomcatApp_profile" {
    name = "TomCat-App-Profile"
    role = aws_iam_role.App_S3_Access.name

    tags = {
        Name = "TomCat App Profile"
        Terraform = "true"
        Environment = "dev"
        LabNumber= "1"
    }
}
