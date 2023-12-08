resource "aws_instance" "app" {
    count = 2

    ami           = var.app_ami
    instance_type = "t2.micro"

    associate_public_ip_address = true

    subnet_id   = aws_subnet.public[count.index].id
    vpc_security_group_ids = [ aws_security_group.apps.id ]

    user_data = file("../resources/ec2_bootstrap.sh")

    tags = {
        Name = "App-${count.index}"
        Project = "Hands-on-4"
        Terraform = "true"
    }
}