terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Retrieve the AWS account number
# To Avoid hardcode it
data "aws_caller_identity" "current" {}

locals {
  aws_account_number = data.aws_caller_identity.current.account_id
}
