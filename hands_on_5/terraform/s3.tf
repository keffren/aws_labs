# Create Athena Query result location for S3 Access logs
resource "aws_s3_bucket" "athena_query_logs" {
    bucket = var.query_result_bucket_location

    tags = {
        Name = var.query_result_bucket_location
        Project = "Hands-on-5"
        Terraform = "true"
    }
}

# Disable Any Public Access
resource "aws_s3_bucket_public_access_block" "athena_query_logs" {
  bucket = aws_s3_bucket.athena_query_logs.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}