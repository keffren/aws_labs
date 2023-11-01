resource "aws_elastic_beanstalk_application" "beanstalk_app" {
    name        = "lab-eb-app"
    description = "EB for practice and learning purposes"

    tags = {
        Terraform = "true"
    }
}

resource "aws_elastic_beanstalk_environment" "beanstalk-dev-env" {
    name                = "lab-eb-env-dev"
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
      namespace = "aws:elasticbeanstalk:environment"
      name = "EnvironmentType"
      value = "SingleInstance"
    }

    setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name      = "IamInstanceProfile"
        value     =  "elastic-Beanstalk-ec2-profile"
    }

    setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name      = "InstanceType"
        value     = "t2.micro"
    }

    tags = {
        Terraform = "true"
    }
}
