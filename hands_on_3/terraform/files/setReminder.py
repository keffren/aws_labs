
import json
import boto3
from botocore.exceptions import ClientError
import datetime

DYNAMODB_REGION = 'eu-west-1'
REMINDERS_TABLE_NAME = "reminders"

def setReminder_handler(event, context):
    
    resp_message = "The reminder has been added successfully"
    status_code = 200

    try:
        # Parsing input data
        userId = event["UserID"]
        id = event["id"]
        time_stamp = datetime.datetime.strptime(event["trigger_date"], "%d/%m/%Y").timestamp()
        reminder_ttl = int(time_stamp)
        reminder_type = event["type"]
        message = event["message"]

        #Connect to DynamoDB and retrieve reminders table
        dynamodb = boto3.resource('dynamodb', region_name='eu-west-1')
        table = dynamodb.Table(REMINDERS_TABLE_NAME)

        # Adding item into DynamoDB table
        table.put_item(
            Item={
                "UserID": userId,
                "id": id,
                "ttl": reminder_ttl,
                "type": reminder_type,
                "message": message 
            }
        )

        resp_message = "The reminder has been added successfully"
        status_code = 200

    except KeyError as e:
        # Handling missing keys in the input event
        resp_message = f"Missing key: {str(e)}"
        status_code = 400
    except ClientError as e:
        # Handling errors related to DynamoDB operations
        resp_message = e.response['Error']['Message']
        status_code = 500
    except Exception as e:
        # Handling unexpected errors
        resp_message = f"Error: {str(e)}"
        status_code = 500

    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
        },
        "body": json.dumps({
            "message": resp_message
        })
    }
