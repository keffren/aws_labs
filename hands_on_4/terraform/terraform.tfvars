#PROVIDER
aws_region = "eu-west-1"

# NETWORK
vpc_cidr_block = "10.0.0.0/16"
public_subnets = ["10.0.1.0/24", "10.0.3.0/24"]
private_subnets = ["10.0.2.0/24", "10.0.4.0/24"]

# EC2 Intances
app_ami = "ami-046a9f26a7f14326b"