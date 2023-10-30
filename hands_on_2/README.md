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
