/* DynamoDB Table attributes
 * Only define attributes on the table object that are going to be used as:
 * Table hash key or range key LSI or GSI hash key or range key
*/

resource "aws_dynamodb_table" "reminders" {
    name           = "reminders"
    billing_mode   = "PROVISIONED"
    read_capacity  = 5
    write_capacity = 5
    hash_key       = "UserID"
    range_key = "id"

    stream_enabled   = true
    stream_view_type = "NEW_AND_OLD_IMAGES"

    attribute {
        name = "UserID"
        type = "S"
    }

    attribute {
        name = "id"
        type = "N"
    }

    global_secondary_index {
        name               = "reminderID"
        hash_key           = "id"
        write_capacity     = 5
        read_capacity      = 5
        projection_type    = "INCLUDE"
        non_key_attributes = ["UserID"]
    }

    ttl {
        attribute_name = "ttl"
        enabled        = true
    }

    tags = {
        Lab = "Hands on n3"
        Terraform = "true"
    }
}

/* HOW ADD A DYNAMODB ITEM USING TERRAFORM

resource "aws_dynamodb_table_item" "email_reminder" {
    table_name = aws_dynamodb_table.reminders.name
    hash_key   = aws_dynamodb_table.reminders.hash_key
    range_key  = aws_dynamodb_table.reminders.range_key

    item = <<-ITEM
    {
        "UserID": {"S": "test@gmail.com"},
        "id": {"N": "123"},
        "ttl": {"N": "1701526400"},
        "type": {"S": "email"},
        "message": {"S": "This is the email content"}
    }
    ITEM
} 
*/

# Allow Lambda functions to get events from DynamoDB
resource "aws_lambda_event_source_mapping" "send_reminder" {
    event_source_arn  = aws_dynamodb_table.reminders.stream_arn
    function_name     = aws_lambda_function.sendReminder.arn
    starting_position = "LATEST"
}