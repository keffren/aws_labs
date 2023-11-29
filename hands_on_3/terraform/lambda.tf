# =======================================  GetReminder LAMBDA FUNCTION
data "archive_file" "getReminder_zip" {
    type        = "zip"
    source_file = "${path.module}/files/getReminder.py"
    output_path = "${path.module}/files/getReminder_function.zip"
}

resource "aws_lambda_function" "getReminder" {
    filename      = "${path.module}/files/getReminder_function.zip"

    function_name = "getReminder"
    role          = aws_iam_role.reminder_service_role.arn
    handler       = "getReminder.getReminder_handler"

    runtime = "python3.11"

    depends_on = [ data.archive_file.getReminder_zip ]

    tags = {
        Lab = "Hands on n3"
        Terraform = "true"
    }
}