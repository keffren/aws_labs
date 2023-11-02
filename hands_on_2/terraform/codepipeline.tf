# Retrieve the GitHub token secret
data "aws_secretsmanager_secret" "github_token" {
  arn = "arn:aws:secretsmanager:eu-west-1:958238255088:secret:lab/codepipeline-qKTTcT"
}
data "aws_secretsmanager_secret_version" "github_token_current" {
  secret_id     = data.aws_secretsmanager_secret.github_token.arn
}

locals {
  github_token = jsondecode(data.aws_secretsmanager_secret_version.github_token_current.secret_string)["aws-eb-repo-token"]
}

resource "aws_codepipeline" "codepipeline" {
    name     = "CD-pipeline-lab"
    role_arn = aws_iam_role.custom_codepipeline_service_role.arn

    artifact_store {
        location = aws_s3_bucket.codepipeline_bucket.bucket
        type     = "S3"
    }

    stage {
        name = "Source"

        action {
            name            = "SourceAction"
            category        = "Source"
            owner           = "ThirdParty"
            provider        = "GitHub"
            version         = "1"  # GitHub version 1
            output_artifacts = ["source_output"]

            configuration = {
                Owner               = "keffren"
                Repo                = "aws-elastic-beanstalk-express-js-sample"
                Branch              = "main"
                OAuthToken          = local.github_token
                PollForSourceChanges = "false" #It'll use webhooks
            }
        }
    }

    stage {
        name = "Build"

        action {
            name             = "BuildAction"
            category         = "Build"
            owner            = "AWS"
            provider         = "CodeBuild"
            region           = "eu-west-1"

            input_artifacts  = ["source_output"]
            output_artifacts = ["build_output"]
            version          = "1"

            configuration = {
                ProjectName = aws_codebuild_project.build.name
            }
        }
    }

    stage {
        name = "Review"

        action {
            name = "ManualAction"
            category = "Approval"
            owner = "AWS"
            provider = "Manual"
            version = "1"
        }
    }
    stage {
        name = "Deploy"

        action {
            name            = "DeployAction"
            category        = "Deploy"
            owner           = "AWS"
            provider        = "ElasticBeanstalk"
            input_artifacts = ["source_output"]
            version         = "1"

            configuration = {
                ApplicationName = "${aws_elastic_beanstalk_application.beanstalk_app.name}"
                EnvironmentName = "${aws_elastic_beanstalk_environment.beanstalk-dev-env.name}"
            }
        }
    }

    tags = {
        Terraform = "true"
    }
}

resource "aws_codepipeline_webhook" "github_webhook_integration" {
    name            = "github-webhook-integration"
    authentication  = "GITHUB_HMAC"
    target_action   = "Source"
    target_pipeline = aws_codepipeline.codepipeline.name

    authentication_configuration {
        secret_token = "super-secret"
    }

    filter {
        json_path    = "$.ref"
        match_equals = "refs/heads/main"
    }

    tags = {
        Terraform = "true"
    }
}
