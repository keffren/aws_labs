resource "aws_s3_bucket" "artifact_bucket" {
    bucket = "hands-on-1-artifacts"

    tags = {
        Name = "Hands-on-1 artifacts"
        Terraform = "true"
        Environment = "dev"
        LabNumber= "1"
    }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.artifact_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}