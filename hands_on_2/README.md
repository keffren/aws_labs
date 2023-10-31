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

Elastic Beanstalk supports a wide range of application configurations, which can make it challenging to manage using Terraform. AWS provides a helpful [guide](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html) that covers the general options for all environments.

> Due to the security policies of AWS, Elastic Beanstalk does not create instance profile role automatically now for new accounts. You need to manually create an instance profile and add the managed policies of AWSElasticBeanstalkWebTier in it. 
The next guide could be helpful : [Elastic Beanstalk instance profile](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts-roles-instance.html).

### Key concepts

- **AWS Elastic Beanstalk -** A service that makes it easy to deploy your application on AWS. You simply upload your code and Elastic Beanstalk deploys, manages, and scales your application.
- **Environment -** Collection of AWS resources provisioned by Elastic Beanstalk that are used to run your application.
- **EC2 instance -** Virtual server in the cloud. Elastic Beanstalk will provision one or more Amazon EC2 instances when creating an environment.
- **Web server -** Software that uses the HTTP protocol to serve content over the Internet. It is used to store, process, and deliver web pages.
    - ![](/hands_on_2/resources/web_env_tier_architecture.png)
- **Platform —** Combination of operating system, programming language runtime, web server, application server, and Elastic Beanstalk components. Your application runs using the components provided by a platform.
    - ***solution_stack_name** defines the platform as terraform argument*
    - solution_stack_name - A solution stack to base your Template off of. Example stacks can be found in the Amazon API documentation
- **Deployment modes -**  There are two deployments modes in Elastic Beanstalk:
    - Single Instance - It's great for dev purposes, and this lab will utilize it.
        - ![](/hands_on_2/resources/single_instance_deployment_type.png)
    - High availability with load balancer - Ideal for production environments with scalability and availability.
