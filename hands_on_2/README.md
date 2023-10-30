# Create Continuous Delivery Pipeline

## OVERVIEW

In this lab I will create a continuous delivery pipeline for a simple web application. 
I will learn how to create a continuous delivery pipeline that will automatically deploy a web application whenever the source code is updated.

[lab-source](https://aws.amazon.com/getting-started/hands-on/create-continuous-delivery-pipeline/)

### What I will accomplish

This tutorial will walk me through the steps to create the continuous delivery pipeline discussed above. I will learn to:

- Create an **AWS Elastic Beanstalk** environment to deploy the application
- Configure **AWS CodeBuild** to build the source code from GitHub
- Use **AWS CodePipeline** to set up the continuous delivery pipeline with source, build, and deploy stages

### Application architecture

The following diagram provides a visual representation of the services used in this tutorial and how they are connected. This application uses GitHub, AWS Elastic Beanstalk, AWS CodeBuild, and AWS CodePipeline.

![project-architecture](/hands_on_2/resources/project_architecture.png)

## AWS Elastic Beanstalk 

It is a compute service that makes it easy to deploy and manage applications on AWS without having to worry about the infrastructure that runs them. 

To deploy AWS Elastic Beanstalk using Terraform, I had to seek additional documentation because the HashiCorp documentation was insufficient. This blog post, [how-to-launch-aws-elastic-beanstalk-using-terraform](https://automateinfra.com/2021/03/24/how-to-launch-aws-elastic-beanstalk-using-terraform/), directed me on how to deploy it through Terraform.

### Key concepts

- **AWS Elastic Beanstalk -** A service that makes it easy to deploy your application on AWS. You simply upload your code and Elastic Beanstalk deploys, manages, and scales your application.
- **Environment -** Collection of AWS resources provisioned by Elastic Beanstalk that are used to run your application.
- **EC2 instance -** Virtual server in the cloud. Elastic Beanstalk will provision one or more Amazon EC2 instances when creating an environment.
- **Web server -** Software that uses the HTTP protocol to serve content over the Internet. It is used to store, process, and deliver web pages.
- **Platform —** Combination of operating system, programming language runtime, web server, application server, and Elastic Beanstalk components. Your application runs using the components provided by a platform.