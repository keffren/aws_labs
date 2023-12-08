# Deploying an Application Load balancer (ALB)

## OVERVIEW

In this lab I will create a simple ALB which forwards traffic into two EC2 instances.
I will learn how to create a simple application load balancer and how it works.

### What I will accomplish

This tutorial will walk me through the steps to create an ALB. I will learn to:

- Create and launch an **AWS ELB** of application type.
- Add **ssl certificate** to the ALB, enabling HTTPS traffic between the alb and the EC2 instances
- Configure **Security Group** for the ALB.
- Configure **Security Group** to allow only inbound traffic from the ALB to the EC2 instances.
- Structuring **Terraform configurations** following the best practices
- Practice with **Terraform variables** to enhance infrastructure readiness
- Practice with **Terraform count Meta-Argument**

### Application architecture       

![](/hands_on_4/resources/alb_architecture.png)

## EC2 

> [!TIP]
> If you are creating Instances in a VPC, use `vpc_security_group_ids` instead `security_groups`. If you use `security_groups`, Terraform will enforce the creation of the instance in every plan/apply

## APPLICATION LOAD BALANCER

To create an Application Load Balancer (ALB) in AWS, the following components are required:

- VPC
- Security Groups
- **At least two Availability Zone**
- **Target Group**
  - A Target Group is a logical group of backend targets, such as EC2 instances or containers, that the ALB forwards traffic to. We need to create a target group and register backend targets with it. Here we are creating for ec2 instances.
- **Listener**: A listener is a process that checks for connection requests from clients, using a specified protocol and port, and forwards them to the ALB. We need to create a listener on the ALB that listens for incoming traffic on a specific port and protocol, and routes it to the appropriate target group.
- SSL Certificate (Optional) — If we want to secure traffic between clients and the ALB using SSL/TLS encryption, you need to obtain and upload an SSL certificate to the ALB.

## Extra notes

### Structuring **Terraform configurations** following the best practices

This [web site](https://www.terraform-best-practices.com/examples/terraform/small-size-infrastructure) helps to understand how to properly structure a Terraform project following best practices.

### Allow only inbound traffic from the ALB to the EC2 instances

The next code shows how to achieve this requirement:

```
resource "aws_security_group" "apps" {
  ...

  ingress {
      description      = "Allow alb HTTPS requests"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      security_groups  = [aws_security_group.alb.id]
  }

  ingress {
      description      = "Allow alb HTTPS requests"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      security_groups  = [aws_security_group.alb.id]
  }

  ...
}
```

### Enable HTTPS communication between ALB and EC2 instances

To enable a security communication between the alb and the ec2 instances using the HTTPS protocol, it is necessary:

- Have an own domain, the domain used in this lab is: `mateodev.cloud`
- Request the ssl certificate on AWS using AWS Certificate Manager (ACM).
  - I have request a ssl certification for this domain: `alb.mateodev.cloud`
  - Validate the certificate requested
- Provide the certificate to the ALB listener
- When the ALB and its resources are deployed, create an alias dns record on Route53:
  - ![](/hands_on_4/resources/alias_dns_record.png)

## Lab result

![](https://github.com/keffren/aws_labs/assets/12472760/1fd3023b-9928-4e89-9563-236a94e63e50)
