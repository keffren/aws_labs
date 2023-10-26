#DB Instance
locals {
  CentOS-Stream-9-AMI = "ami-009f51225716cb42f"
  amazon-linux-2023 = "ami-046a9f26a7f14326b"
}

/* resource "aws_network_interface" "mysql_db_backend" {
  subnet_id   = aws_subnet.main_subnet.id
  private_ips = ["10.0.1.100"]

  tags = {
    Name = "mysql-db-backend"
    Terraform = "true"
    Environment = "dev"
    LabNumber= "1"
  }
}
 */

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

/* resource "aws_eip" "mysql_db_backend" {
  domain = "vpc"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.mysql_db_backend.id
  allocation_id = aws_eip.mysql_db_backend.id
}  */