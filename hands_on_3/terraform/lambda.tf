# =======================================  GET Reminder LAMBDA FUNCTION
data "archive_file" "getReminder_zip" {
    type        = "zip"
    source_file = "${path.module}/files/getReminder.py"
    output_path = "${path.module}/files/getReminder_function.zip"
}

resource "aws_lambda_function" "getReminder" {
    filename      = "${path.module}/files/getReminder_function.zip"
    source_code_hash = data.archive_file.getReminder_zip.output_base64sha256

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

# =======================================  SET Reminder LAMBDA FUNCTION
data "archive_file" "setReminder_zip" {
    type        = "zip"
    source_file = "${path.module}/files/setReminder.py"
    output_path = "${path.module}/files/setReminder_function.zip"
}

resource "aws_lambda_function" "setReminder" {
    filename      = "${path.module}/files/setReminder_function.zip"
    source_code_hash = data.archive_file.setReminder_zip.output_base64sha256

    function_name = "setReminder"
    role          = aws_iam_role.reminder_service_role.arn
    handler       = "setReminder.setReminder_handler"

    runtime = "python3.11"

    depends_on = [ data.archive_file.setReminder_zip ]

    tags = {
        Lab = "Hands on n3"
        Terraform = "true"
    }
}

# =======================================  SEND Reminder LAMBDA FUNCTION
data "archive_file" "sendReminder_zip" {
    type        = "zip"
    source_file = "${path.module}/files/sendReminder.py"
    output_path = "${path.module}/files/sendReminder_function.zip"
}

resource "aws_lambda_function" "sendReminder" {
    filename      = "${path.module}/files/sendReminder_function.zip"
    source_code_hash = data.archive_file.sendReminder_zip.output_base64sha256

    function_name = "sendReminder"
    role          = aws_iam_role.reminder_service_role.arn
    handler       = "sendReminder.sendReminder_handler"

    runtime = "python3.11"

    depends_on = [ data.archive_file.sendReminder_zip ]

    tags = {
        Lab = "Hands on n3"
        Terraform = "true"
    }
}