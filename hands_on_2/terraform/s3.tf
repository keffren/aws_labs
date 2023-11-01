resource "aws_s3_bucket" "codepipeline_bucket" {
    bucket = "lab-codepipeline-artifacts"

    tags = {
        Terraform = "true"
    }
}
