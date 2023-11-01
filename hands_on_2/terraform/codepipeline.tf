# Retrieve the GitHub token secret
data "aws_secretsmanager_secret" "github_token" {
  arn = "arn:aws:secretsmanager:eu-west-1:958238255088:secret:lab/codepipeline-qKTTcT"
}
data "aws_secretsmanager_secret_version" "github_token_current" {
  secret_id     = data.aws_secretsmanager_secret.github_token.id
}

resource "aws_codepipeline" "codepipeline" {
    name     = "CD-pipeline"
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
                OAuthToken          = "${data.aws_secretsmanager_secret_version.github_token_current.secret_string}"
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
                ProjectName = "lab-dev"
            }
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
