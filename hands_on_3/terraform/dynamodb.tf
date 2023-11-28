/* DynamoDB Table attributes
 * Only define attributes on the table object that are going to be used as:
 * Table hash key or range key LSI or GSI hash key or range key
*/

resource "aws_dynamodb_table" "reminders" {
    name           = "Reminders"
    billing_mode   = "PROVISIONED"
    read_capacity  = 5
    write_capacity = 5
    hash_key       = "userid"

    attribute {
        name = "userid"
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
        non_key_attributes = ["userid"]
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

resource "aws_dynamodb_table_item" "email_reminder" {
    table_name = aws_dynamodb_table.reminders.name
    hash_key   = aws_dynamodb_table.reminders.hash_key

    item = <<-ITEM
    {
        "userid": {"S": "test@gmail.com"},
        "id": {"N": "123"},
        "ttl": {"N": "1648842828"},
        "type": {"S": "email"},
        "message": {"S": "This is the email content"}
    }
    ITEM

    lifecycle {
        ignore_changes = all
    }
}

resource "aws_dynamodb_table_item" "sms_reminder" {
    table_name = aws_dynamodb_table.reminders.name
    hash_key   = aws_dynamodb_table.reminders.hash_key

    item = <<-ITEM
    {
        "userid": {"S": "34618096294"},
        "id": {"N": "456"},
        "ttl": {"N": "1648842828"},
        "type": {"S": "sms"},
        "message": {"S": "This is the sms content"}
    }
    ITEM

    lifecycle {
        ignore_changes = all
    }
}
