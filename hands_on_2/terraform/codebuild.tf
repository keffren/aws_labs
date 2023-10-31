resource "aws_codebuild_project" "build" {
    name          = "test-project"
    description   = "test_codebuild_project"

    service_role = "${aws_iam_role.custom_codebuild_service_role.arn}"
    
    source {
    type            = "GITHUB"
    location        = "https://github.com/keffren/aws-elastic-beanstalk-express-js-sample"
    git_clone_depth = 1
    
    buildspec = <<-EOF
        version: 0.2
        phases:
            build:
                commands:
                    - npm i --save
        artifacts:
            files:
                - '**/*'
    EOF
        git_submodules_config {
            fetch_submodules = true
        }
    }

    environment {
        compute_type                = "BUILD_GENERAL1_SMALL"
        image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
        type                        = "LINUX_CONTAINER"
        image_pull_credentials_type = "CODEBUILD"

        privileged_mode = true
    }

    artifacts {
        type = "NO_ARTIFACTS"
    }

    logs_config {
        cloudwatch_logs {
            status = "DISABLED"
        }

        s3_logs {
            status = "DISABLED"
        }
    }

    tags = {
        Terraform = "true"
    }
}
