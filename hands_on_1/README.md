# OVERVIEW: Three Tier Web App

This lab is part of the Udemy course [DevOps Projects | 20 Real Time DevOps Projects](https://www.udemy.com/share/103WIY3@wraVu0Li5V4Mlmx3PC3QofPOM3CJBlmqhG9LvmQG6wK6GOhX3IO1ltaVIl8RjWwf/) by Imran Teli, which features real DevOps projects.

Furthermore, I will deploy this project as Infrastructure as Code (IaC) using Terraform to practice and enhance my Terraform skills.

[Official lab repository](https://github.com/devopshydclub/vprofile-project/tree/aws-LiftAndShift)

Architecture:

![three_tier_architecture](/hands_on_1/resources/handson_1_architecture.drawio.png)

## Flow of execution

  - Create the network infrastructure
    - VPC, Internet GateWay, Subnets and Tables Routes
  - Create Security groups for the instances Which this project will use.
  - Launch Instances with user data (bootstrapping)
  - Update IP to name mapping in route
  - Create S3 bucket
  - Build Application from source code
  - Upload to S3
  - Download artifact to Tomcat Ec2 instance through IAM role
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

## Route 53

> Private zones require at least one VPC association at all times.

## S3

### aws_s3_bucket_public_access_block

Manages S3 bucket-level Public Access Block configuration. For more information about these settings, see [the AWS S3 Block Public Access documentation](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html).

Guarantee the bucket have not any public access:
```
block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true
```

## Artifact

It needs to create an IAM user, without login credentials, to allow copy the artifact from the ubuntu container to the S3 bucket using the AWS-CLI.

This IAM user has to have S3 permissions. Therefore it has created access-key and attached the AWS managed policy: `AmazonS3FullAccess`.

The course shows how to build the artifact in local, but I prefer doi it deploying a docker container which contains an Ubuntu image.

```
docker pull ubuntu
docker run -it --rm ubuntu
apt update

#Install jdk8
apt install openjdk-8-jdk -y

#Install Maven
apt install maven -y

#Install git
apt install -y

#Install AWS-CLI and configure AWS profile
apt instal awscli -y
aws configure

# Download repository that creates the artifact
cd
git clone -b aws-LiftAndShift https://github.com/devopshydclub/vprofile-project.git

# Modify MYSQL, TomCat MemCache and RabbitMQ entrypoints
cd vprofile-project/
apt install nano
nano src/main/resources/application.properties 

# Build Artifact
mvn install

# Check the entrypoints which have edited
cat target/vprofile-v2/WEB-INF/classes/application.properties

#Copy the artifact built into the S3 bucket
aws s3 cp target/vprofile-v2.war s3://hands-on-1-artifacts/
```

## IAM 

The **TomCat app** needs to copy the artifact stored on the S3 Bucket. Hence It'll access to S3 assuming a role as AWS best practices.

This role will allows EC2 instances to call AWS services on your behalf.

How Can we provide an IAM role to an EC2 instance using terraform?
  - Create an IAM Instance Profile 
  - Attach the IAM Instance Profile to the EC2

## Deploy the artifact on TomCat App

Connect to TomCat App using SSH:

```
sudo -i
systemctl stop tomcat9

rm -rf /var/lib/tomcat9/webapps/ROOT
cp /tmp/vprofile-v2.war /var/lib/tomcat9/webapps/ROOT.war

systemctl start tomcat9


ls /var/lib/tomcat9/webapps/
# OUTPUT:  ROOT ROOT.war

cat /var/lib/tomcat9/webapps/ROOT/WEB-INF/classes/application.properties
# OUTPUT: Same file that It was edited previously
```

# LOAD BALANCER

To create an Application Load Balancer (ALB) in AWS, the following components are required:

- VPC
- Security Groups
- **At least two Availability Zone**
- **Target Group**
  - A Target Group is a logical group of backend targets, such as EC2 instances or containers, that the ALB forwards traffic to. We need to create a target group and register backend targets with it. Here we are creating for ec2 instances.
- **Listener**: A listener is a process that checks for connection requests from clients, using a specified protocol and port, and forwards them to the ALB. We need to create a listener on the ALB that listens for incoming traffic on a specific port and protocol, and routes it to the appropriate target group.
- SSL Certificate (Optional) — If we want to secure traffic between clients and the ALB using SSL/TLS encryption, you need to obtain and upload an SSL certificate to the ALB.
  - In this lab, the SSL encryption is enable.

Once these components are in place, we can create an ALB.

## AUTO-SCALING GROUP

To deploy an Auto Scaling Group (ASG) on AWS using Terraform, it needs to define a few components and configurations.
Here are the key elements for an Auto Scaling Group deployment:

- **Launch Configuration or Launch Template:** 
  - You need to specify the configuration for the instances that the ASG will launch. 
  A Launch Configuration specifies instance details like the Amazon Machine Image (AMI), while a Launch Template is a more flexible and recommended way to define instance configurations.
- **Auto Scaling Group:** 
  - Define the Auto Scaling Group itself, specifying details like the desired capacity, minimum and maximum capacity, the availability zones, the VPC, and the health check settings.
- **Load Balancer Configuration (optional):** 
  - If you want instances to register with a load balancer, you can define the load balancer and configure the ASG to use it. So you have to attach the Auto-Scaling group with the load balancer.
- **Scaling Policies (optional):**
  - You can define scaling policies to automate the scaling of your ASG based on conditions such as CPU utilization, request counts, or custom metrics.
  