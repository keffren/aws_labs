# OVERVIEW

TO DO

[Official project repository](https://github.com/devopshydclub/vprofile-project/tree/aws-LiftAndShift)

Architecture:

- TO DO

## Flow of execution

  - Create the network infrastructure
    - VPC, Internet GateWay, Subnets and Tables Routes
  - Create Security groups for the instances Which this project will use.
  - Launch Instances with user data (bootstrapping)
  - Update IP to name mapping in route
  - Build Application from source code
  - Upload to S3
  - Download artifact to Tomcat Ec2 instance
  - Setup ELB with HTTPS (certificate from Amazon Certificate Manager)
  - Map ELB Endpoint to website name in Godaddy DNS
  - Validate
  - Build AutoScaling Group for Tomcat Instances

## Creating a new VPC

The idea of this repository is to consolidate and improve the AWS knowledge. Therefore I will create the network infrastructure (*network.tf*) at low level abstraction. 

In order to create a new VPC, it needs to declare:

- **Internet Gateway:**
    - Gateway for connecting your AWS VPC to the internet.
    - Enables communication between VPC instances and the public internet.
- **Subnet:**
    - Segmented part of your VPC's IP address space.
    - Used for organizing and isolating resources within your VPC
- **Route table:**
    - A set of rules that determine how network traffic is directed.
    - Controls the flow of traffic within and in/out of your VPC subnets.
        - **Route table association:**
            - Links a subnet to a specific route table.
            - Specifies how traffic is routed in and out of that subnet.

Example of VPC underlay:

![vpc-architecture](/hands_on_1/resources/vpc_architecture_example%20.png)

Create a VPC at high level using [AWS VPC Terraform module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest):

```
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "main-vpc"
  cidr = "10.0.0.0/16"

  # Availability Zones
  azs             = ["eu-west-1a"]

  #Subnets
  public_subnets  = ["10.0.1.0/24"]

  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
    LabNumber= "1"
  }
}
```

## Creating security groups

**Security Group:** 
A security group in AWS is a virtual firewall that controls inbound and outbound traffic to AWS resources, such as instances. It acts as a set of rules that specify which network traffic is allowed or denied, providing security and access control for these resources

For this project, I am going to create three securities groups:

  - Load Balancer Security-Group
    - Inbound traffic: internet
  - Tomcat App Security-Group
    - Inbound traffic:
      - Traffic from  ALB
      - Allow SSH connection
  - Backend App Services Security-Group
    - Inbound traffic:
      - Traffic from Tomcat web server
      - Intern traffic
      - Allow SSH connection

There isn't an protocol type within Ingres block to define MYSQL/Aurora type, but check this:
![tcp_types](/hands_on_1/resources/tcp_types.png)

How can I declare all inbound traffic within ingress in terraform?
![](/hands_on_1/resources/sg_inbound_rule.png)
```
ingress {
    description      = "Allow all traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    
    #If you want to allow traffic from a specify SG or CIDR blocks:
    #security_groups  = [ ]
    #self = true                -> It references itself SG
    #cidr_blocks      = [ ]
  }
```

## Deploy EC2 Instances

### MYSQL DB Instance issue: CentOS-Stream-9

**TERRAFORM Error:** *creating EC2 Instance: OptInRequired: In order to use this AWS Marketplace product you need to accept terms and subscribe*

To fix this issue, it needs:

  - You will need an AWS License Manager service linked role (SLR) to see license entitlement information on this page. To enable connectivity between AWS Marketplace and AWS License Manager, please set up SLR in the AWS License Manager Console.
  - [Subscribe and accept the terms](https://aws.amazon.com/marketplace/pp/prodview-k66o7o642dfve) through AWS CONSOLE before deploy it using terraform.

*How check the user-data of an EC2 deployed?*
There are two ways to check the user-data:

  - Using AWS Console:
    - `Navigate to AWS Console > EC2 > Select the deployed Instance > Actions > Instance settings > Edit user data`
  - Within the EC2 Instance:
    - `curl http://169.254.169.254/latest/user-data`


### Validate the EC2 deployments

Previously, I added an ingress rule to the security groups that allow SSH connections. Therefore, the validation consists of accessing into the EC2 instances and checking the status of the DB and the deployed services.

- TomCat Memcache
  ```
  sudo -i
  ss -tunlp | grep 11211
  ```
- RabbitMQ
  ```
  sudo -i
  systemctl status rabbitmq-server
  ```
- TomCat App
  ```
  sudo -i
  systemctl status tomcat9

  #Check the app path, it should print ROOT
  ls /var/lib/tomcat9/webapps/ 
  ```
- DB Instance: MYSQL
  ```
  sudo -i
  systemctl status mariadb

  #Access into th DB
  mysql -u admin -padmin123 accounts
  show tables;
  ```

## ROUTE 53

> Private zones require at least one VPC association at all times.