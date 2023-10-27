# Assume role policy
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions   = [
        "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Grant S3 Access to EC2 instances
resource "aws_iam_role" "App_S3_Access" {
  name               = "App-S3-Access"

  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]

  tags = {
    Name = "App-S3-Access"
    Terraform = "true"
    Environment = "dev"
    LabNumber= "1"
  }
}
