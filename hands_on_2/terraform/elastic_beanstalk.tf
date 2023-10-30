resource "aws_elastic_beanstalk_application" "beanstalk_app" {
    name        = "elastic-lab-app"
    description = "Deploy and manage applications"
}

/*
resource "aws_elastic_beanstalk_environment" "beanstalk-env" {
  name                = "beanstalk-env-lab"
  application         = aws_elastic_beanstalk_application.beanstalk_app.name
  solution_stack_name = "64bit Amazon Linux 2 v5.8.7 running Node.js 18"

  tier = "WebServer"

    setting {
        namespace = "aws:ec2:vpc"
        name      = "VPCId"
        value     = aws_vpc.main_vpc.id
    }

    setting {
        namespace = "aws:ec2:vpc"
        name      = "Subnets"
        value     = aws_subnet.main_subnet.id
    }

    setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name      = "IamInstanceProfile"
        value     =  "aws-elasticbeanstalk-ec2-role"
    }

    setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
    }
}
*/