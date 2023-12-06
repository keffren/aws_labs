variable "aws_region" {
  type     = string
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  type     = string
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overriden"
  default = "0.0.0.0/0"
}

variable "public_subnets" {
  type     = list(string)
}

variable "private_subnets" {
  type     = list(string)
}