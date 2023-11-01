# Create Continuous Delivery Pipeline

## OVERVIEW

In this lab I will create a continuous delivery pipeline for a simple web application. 
I will learn how to create a continuous delivery pipeline that will automatically deploy a web application whenever the source code is updated.

The tutorial project is provided by AWS : [project-source](https://aws.amazon.com/getting-started/hands-on/create-continuous-delivery-pipeline/)

### What I will accomplish

This tutorial will walk me through the steps to create the continuous delivery pipeline discussed above. I will learn to:

- Create an **AWS Elastic Beanstalk** environment to deploy the application
- Configure **AWS CodeBuild** to build the source code from GitHub
- Use **AWS CodePipeline** to set up the continuous delivery pipeline with source, build, and deploy stages

### Application architecture

The following diagram provides a visual representation of the services used in this tutorial and how they are connected. This application uses GitHub, AWS Elastic Beanstalk, AWS CodeBuild, and AWS CodePipeline.

![project-architecture](/hands_on_2/resources/project_architecture.png)

## AWS Elastic Beanstalk 
<details>
<summary>It is a compute service that makes it easy to deploy and manage applications on AWS without having to worry about the infrastructure that runs them.</summary>

Elastic Beanstalk supports a wide range of application configurations, which can make it challenging to manage using Terraform. AWS provides a helpful [guide](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html) that covers the general options for all environments.

> [!IMPORTANT]
> Due to the security policies of AWS, Elastic Beanstalk does not create instance profile role automatically now for new accounts. You need to manually create an instance profile and add the managed policies of AWSElasticBeanstalkWebTier in it. 
The next guide could be helpful : [Elastic Beanstalk instance profile](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts-roles-instance.html).

### Key concepts

- **AWS Elastic Beanstalk -** A service that makes it easy to deploy your application on AWS. You simply upload your code and Elastic Beanstalk deploys, manages, and scales your application.
- **Environment -** Collection of AWS resources provisioned by Elastic Beanstalk that are used to run your application.
- **EC2 instance -** Virtual server in the cloud. Elastic Beanstalk will provision one or more Amazon EC2 instances when creating an environment.
- **Web server -** Software that uses the HTTP protocol to serve content over the Internet. It is used to store, process, and deliver web pages.
    - ![](/hands_on_2/resources/web_env_tier_architecture.png)
- **Platform —** Combination of operating system, programming language runtime, web server, application server, and Elastic Beanstalk components. Your application runs using the components provided by a platform.

- **Deployment modes -**  There are two deployments modes in Elastic Beanstalk:
    - Single Instance - It's great for dev purposes, and this lab will utilize it.
        - ![](/hands_on_2/resources/single_instance_deployment_type.png)
    - High availability with load balancer - Ideal for production environments with scalability and availability.

### Terraform notes

- ***solution_stack_name** defines the platform as terraform argument*
    - solution_stack_name - A solution stack to base your Template off of. Example stacks can be found in the Amazon API documentation

</details>

## CodeBuild

<details>
<summary>AWS CodeBuild build the source code previously stored in the GitHub repository. AWS CodeBuild is a fully managed continuous integration service that compiles source code, runs tests, and produces software packages that are ready to deploy.</summary>

[GitHub repository](https://github.com/keffren/aws-elastic-beanstalk-express-js-sample)

### Key concepts

- **Build process —** Process that converts source code files into an executable software artifact. It may include the following steps: compiling source code, running tests, and packaging software for deployment.

- **Continuous integration —** Software development practice of regularly pushing changes to a hosted repository, after which automated builds and tests are run.

- **Build environment —** Represents a combination of the operating system, programming language runtime, and tools that CodeBuild uses to run a build.

- **Buildspec —** Collection of build commands and related settings, in YAML format, that CodeBuild uses to run a build.

- **Build Project —** Includes information about how to run a build, including where to get the source code, which build environment to use, which build commands to run, and where to store the build output.

- **OAuth —** Open protocol for secure authorization. OAuth enables you to connect your GitHub account to third-party applications, including AWS CodeBuild.

- **Artifact -** refers to the output generated during the build process of a project. These artifacts are the files created as a result of compiling your source code. Artifacts can include binary files, libraries, executables, and other products produced during the compilation.

### Terraform notes

- `service_role` - (**Required**) Amazon Resource Name (ARN) of the AWS Identity and Access Management (IAM) role that enables AWS CodeBuild to interact with dependent AWS services on behalf of the AWS account.

</details>

## CodePipeline

<details>
<summary>In this module, I will use AWS CodePipeline to set up a **continuous delivery** pipeline with source, build, and deploy stages. The pipeline will detect changes in the code stored in your GitHub repository, build the source code using AWS CodeBuild, and then deploy your application to AWS Elastic Beanstalk.</summary>

## Key concepts

- **Continuous delivery** — Software development practice that allows developers to release software more quickly by automating the build, test, and deploy processes.

- **Pipeline —** Workflow model that describes how software changes go through the release process. Each pipeline is made up of a series of stages.

- **Stage —** Logical division of a pipeline, where actions are performed. A stage might be a build stage, where the source code is built and tests are run. It can also be a deployment stage, where code is deployed to runtime environments.

- **Action —** Set of tasks performed in a stage of the pipeline. For example, a source action can start a pipeline when source code is updated, and a deploy action can deploy code to a compute service like AWS Elastic Beanstalk.

## Terraform notes

- *How Can we know the stage structure?*
    - [CodePipeline-structure](https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html)
- `artifact_store` - **(Required)** One or more artifact_store blocks.
    - `location` - **(Required)** The location where AWS CodePipeline stores artifacts for a pipeline; **currently only S3 is supported**. So it must be a S3 bucket created.
- Adding a GitHub version 1 source action
    - `OAuthToken` - (**Required**) Represents the GitHub authentication token that allows CodePipeline to perform operations on your GitHub repository. **This will be stored as a secret in AWS Secrets Manager**.
- *How Can we retrieve a secret from AWS Secret Manager using Terraform?*
    ```
    data "aws_secretsmanager_secret_version" "example_secret" {
        secret_id     = "your-secret-name"
        version_stage = "AWSCURRENT"
    }
    ```

</details>
