data "aws_iam_policy" "AWSElasticBeanstalkWebTier" {
  name = "AWSElasticBeanstalkWebTier"
}

data "aws_iam_policy" "AWSElasticBeanstalkMulticontainerDocker" {
  name = "AWSElasticBeanstalkMulticontainerDocker"
}

# Create CustomServiceRoleForElasticBeanstalk

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