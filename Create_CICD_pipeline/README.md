# LAB OVERVIEW

This lab demonstrates how to build a fully managed continuous integration and continuous delivery (CI/CD) pipeline for applications that run on Amazon Elastic Container Service (Amazon ECS). It use AWS CodePipeline to model, orchestrate, and visualize a three-stage pipeline that deploys a containerized application.

This lab use the following technology stack:

- AWS CodeBuild
- AWS CodeCommit
- AWS CodeDeploy
- AWS CodePipeline
- Amazon Elastic Container Registry (Amazon ECR)
- Amazon ECS

# TASK 1: Fargate configuration

In this task, you connect to a basic application that displays news about Amazon Web Services (AWS). **The application has been deployed on Amazon ECS using the AWS Fargate launch type**.

## APP

The APP will be deployed using a dockerfile:

```
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
FROM public.ecr.aws/d5z8k9g9/node18-alpine3.15:latest

# Create app directory
WORKDIR /usr/src/app

# App dependencies
COPY package.json ./

# Download the dependencies listed in the package.json file and create the node_modules directory
RUN npm install

# Copy the application source code
COPY index.js .
COPY routes ./routes
COPY static ./static

# Listen on port 80
EXPOSE 80

# Start the application
CMD [ "node", "index.js" ]
```

However, to launch this application on Amazon ECS and build a pipeline that automates its deployment, you need three additional files:

- **buildspec.yaml**: CodeBuild uses the commands and parameters in the buildspec file to build a Docker image.
```
cat << 'EOF' > ~/environment/buildspec.yaml
version: 0.2

phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws --version
      - ACCOUNT_ID=$(echo $CODEBUILD_BUILD_ARN | cut -f5 -d ':') && echo "The Account ID is $ACCOUNT_ID"
      - echo "The AWS Region is $AWS_DEFAULT_REGION"
      - REPOSITORY_URI=$ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$ACCOUNT_ID-application
      - echo "The Repository URI is $REPOSITORY_URI"
      - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $REPOSITORY_URI
      - COMMIT_HASH=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7)
      - IMAGE_TAG=$COMMIT_HASH
  build:
    on-failure: ABORT
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - docker build -t $REPOSITORY_URI:$IMAGE_TAG .
      - docker tag $REPOSITORY_URI:$IMAGE_TAG $REPOSITORY_URI:$IMAGE_TAG
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image...
      - docker push $REPOSITORY_URI:$IMAGE_TAG
      - echo Writing image definitions file...
      - printf '[{"name":”myimage","imageUri":"%s"}]' $REPOSITORY_URI:$IMAGE_TAG > imagedefinitions.json
      - printf '{"ImageURI":"%s"}' $REPOSITORY_URI:$IMAGE_TAG > imageDetail.json
artifacts:
    files:
      - imagedefinitions.json
      - imageDetail.json
      - appspec.yaml
      - taskdef.json
EOF
```
- **appspec.yaml**: CodeDeploy uses the appspec file to select a task definition.
```
cat << EOF > ~/environment/appspec.yaml
version: 0.0
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: <TASK_DEFINITION>
        LoadBalancerInfo:
          ContainerName: "application"
          ContainerPort: 80
EOF
```
- **taskdef.json**: Recall that all three tasks that are currently running in your Amazon ECS service reference the same task definition. After updating the application source code and building a new container, you need a second task definition that points to it. The taskdef.json file is used to create this new task definition that points to your updated application image.

```
AWS_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
FAMILY=$(aws ecs list-task-definition-families --status ACTIVE --output text | awk '{print $NF}')
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
printf "You are using $AWS_REGION region\nYour task definition family is $FAMILY\nYour account ID is $ACCOUNT_ID\n"

```

```
cat << EOF > ~/environment/taskdef.json
{
    "containerDefinitions": [
        {
            "name": "application",
            "image": "<IMAGE_NAME>",
            "portMappings": [
                {
                    "containerPort": 80,
                    "hostPort": 80,
                    "protocol": "tcp"
                }
            ],
            "essential": true,
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "cicd-logs",
                    "awslogs-region": "$AWS_REGION",
                    "awslogs-stream-prefix": "ecs"
                },
            },
        }
    ],
    "family": "$FAMILY",
    "taskRoleArn": "arn:aws:iam::$ACCOUNT_ID:role/ecsTaskExecutionRole",
    "executionRoleArn": "arn:aws:iam::$ACCOUNT_ID:role/ecsTaskExecutionRole",
    "networkMode": "awsvpc",
    "status": "ACTIVE",
    "compatibilities": [
        "EC2",
        "FARGATE"
    ],
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "cpu": "256",
    "memory": "512",
    "tags": [
        {
            "key": "Name",
            "value": "GreenTaskDefinition"
        }
    ]
}
EOF
```