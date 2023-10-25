# OVERVIEW

TO DO

Architecture:

- TO DO

## Creating a new VPC

The idea of this repository is to consolidate and improve the AWS knowledge. Therefore I will create the network infrastructure (*network.tf*) at low level abstraction. 

In order to create a new VPC, it needs to declare:

- Internet Gateway
    Gateway for connecting your AWS VPC to the internet.
    Enables communication between VPC instances and the public internet.
- Subnet
    Segmented part of your VPC's IP address space.
    Used for organizing and isolating resources within your VPC
- Route table
    A set of rules that determine how network traffic is directed.
    Controls the flow of traffic within and in/out of your VPC subnets.
    - Route table association
        Links a subnet to a specific route table.
        Specifies how traffic is routed in and out of that subnet.

Example of VPC underlay:

![vpc-architecture](/hands_on_1/resources/vpc_architecture_example%20.png)

Create a VPC at high level:

```
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "main-vpc"
  cidr = "10.0.0.0/16"

  # Availability Zones
  azs             = ["eu-west-1a"]

  #Subnets
  public_subnets  = ["10.0.1.0/24"]

  #enable_nat_gateway = true
  #enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
    LabNumber= "1"
  }
}
```

[AWS VPC Terraform module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)

## Creating the auto-scaling security group

TO DO