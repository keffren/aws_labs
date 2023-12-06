# Deploying an Application Load balancer (ALB) [WIP]

## OVERVIEW

In this lab I will create a simple ALB which forwards traffic into two EC2 instances.
I will learn how to create a simple application load balancer and how it works.

### What I will accomplish

This tutorial will walk me through the steps to create an ALB. I will learn to:

- Create and launch an **AWS ELB** of application type.
- Configure **Security Group** for the ALB.
- Configure **Security Group** to allow only inbound traffic from the ALB to the EC2 instances.
- Structuring **Terraform configurations** following the best practices
- Practice with **Terraform variables** to enhance infrastructure readiness
- Practice with **Terraform count Meta-Argument**

### Application architecture       

TO DO

## APPLICATION LOAD BALANCER

To create an Application Load Balancer (ALB) in AWS, the following components are required:

- VPC
- Security Groups
- **At least two Availability Zone**
- **Target Group**
  - A Target Group is a logical group of backend targets, such as EC2 instances or containers, that the ALB forwards traffic to. We need to create a target group and register backend targets with it. Here we are creating for ec2 instances.
- **Listener**: A listener is a process that checks for connection requests from clients, using a specified protocol and port, and forwards them to the ALB. We need to create a listener on the ALB that listens for incoming traffic on a specific port and protocol, and routes it to the appropriate target group.
- SSL Certificate (Optional) — If we want to secure traffic between clients and the ALB using SSL/TLS encryption, you need to obtain and upload an SSL certificate to the ALB.
