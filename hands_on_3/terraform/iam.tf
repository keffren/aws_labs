resource "aws_iam_role" "reminder_service_role" {
    name = "reminder-service-role"
  
    assume_role_policy = <<-EOF
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "lambda.amazonaws.com"
                    },
                    "Action": "sts:AssumeRole"
                }
            ]
        }
    EOF

    tags = {
        Lab = "Hands on n3"
        Terraform = "true"
    }
}

# TO DO: DONT HARDCODE DYNAMODB ARN

resource "aws_iam_policy" "reminder_lambda_permissions" {
    name        = "reminder-lambda-permissions"
    path        = "/"
    description = "Grant permissions to the lambda function "

    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": "logs:CreateLogGroup",
                "Resource": "arn:aws:logs:eu-west-1:${local.aws_account_number}:*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                "Resource": [
                    "arn:aws:logs:eu-west-1:${local.aws_account_number}:log-group:/aws/lambda/*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": "dynamoDB:*",
                "Resource": "${aws_dynamodb_table.reminders.arn}"
            }
        ]
    })

    tags = {
        Lab = "Hands on n3"
        Terraform = "true"
    }
}

resource "aws_iam_role_policy_attachment" "lambda_service_role_attachment" {
    role = aws_iam_role.reminder_service_role.name
    policy_arn = aws_iam_policy.reminder_lambda_permissions.arn
}
