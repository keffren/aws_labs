import json
import boto3

DYNAMODB_REGION = 'eu-west-1'
REMINDERS_TABLE_NAME = "reminders"

def getReminder_handler(event, context):
    
    try:
        user_id = event["UserID"]
        reminder_id = event["id"]

        # Access to DynamoDB Table
        dynamodb = boto3.resource('dynamodb', region_name=DYNAMODB_REGION)
        table = dynamodb.Table(REMINDERS_TABLE_NAME)

        # Retrieve the reminder item  from reminders table
        response = table.get_item(
            Key={
                'UserID': user_id,
                'id': reminder_id
            }
        )

        if "Item" in response:
            status_code = 200
            body_resp = response['Item']
        else:
            status_code = 404  # Changed to represent 'Not Found'
            body_resp = {"message": "No matching reminder found"}

    except KeyError as e:
        status_code = 400  # Bad Request due to missing keys in the event
        body_resp = {"message": f"Missing key: {str(e)}"}
    except Exception as e:
        status_code = 500  # Internal Server Error
        body_resp = {"message": f"Error: {str(e)}"}

    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
        },
        "body": json.dumps(body_resp, default=str)
    }
