data "aws_iam_policy" "AWSElasticBeanstalkWebTier" {
  name = "AWSElasticBeanstalkWebTier"
}
data "aws_iam_policy" "AWSElasticBeanstalkMulticontainerDocker" {
  name = "AWSElasticBeanstalkMulticontainerDocker"
}

# Create Role for ELASTIC BEANSTALK

## Allow assume role
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

# Grant permission for the ec2 launched through Elastic Beanstalk
resource "aws_iam_role" "Custom_ElasticBeanstalk_Ec2_Role" {
    name               = "CustomElasticBeanstalkEc2Role"
    path               = "/"
    assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
    managed_policy_arns = [
        data.aws_iam_policy.AWSElasticBeanstalkWebTier.arn,
        data.aws_iam_policy.AWSElasticBeanstalkMulticontainerDocker.arn
    ]

    tags = {
        Terraform = "true"
    }
}

resource "aws_iam_instance_profile" "elastic-Beanstalk-ec2-profile" {
    name = "elastic-Beanstalk-ec2-profile"
    role = aws_iam_role.Custom_ElasticBeanstalk_Ec2_Role.name

    tags = {
        Terraform = "true"
    }
}

# Create role for CODEBUILD

## Allow assume role
data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
## Grant permission for CodeBuild to interact with dependent AWS services
resource "aws_iam_role" "custom_codebuild_service_role" {
    name               = "custom-codebuild-service-role"
    assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json

    tags = {
        Terraform = "true"
    }
}

## Policy
data "aws_iam_policy_document" "codebuild_service" {
  statement {
      effect = "Allow"

      actions = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
      ]

      resources = ["*"]
  }

  statement {
      effect = "Allow"

      actions = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs",
      ]

      resources = ["*"]
  }

  statement {
      effect    = "Allow"
      actions   = ["ec2:CreateNetworkInterfacePermission"]
      resources = ["arn:aws:ec2:us-east-1:123456789012:network-interface/*"]

    condition {
        test     = "StringEquals"
        variable = "ec2:Subnet"

        values = [
            aws_subnet.main_subnet.arn,
        ]
    }

    condition {
        test     = "StringEquals"
        variable = "ec2:AuthorizedService"
        values   = ["codebuild.amazonaws.com"]
    }
  }
}

## Attach role-policy
resource "aws_iam_role_policy" "attach_policy_codebuild_role" {
  role   = aws_iam_role.custom_codebuild_service_role.name
  policy = data.aws_iam_policy_document.codebuild_service.json
}