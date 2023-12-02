import json
import boto3

AWS_REGION = 'eu-west-1'

def send_email_reminder(email_receiver, reminder):

    ses_client = boto3.client("sesv2", region_name=AWS_REGION)

    email_content = {
            'Destination': {
                'ToAddresses': [email_receiver]
            },
            'Content': {
                'Simple': {
                    'Subject': {
                        'Data': 'Testing Amazon SES'
                    },
                    'Body': {
                        'Text': {
                            'Data': reminder
                        }
                    }
                }
            },
            'FromEmailAddress': 'keffren.dev@gmail.com'
        }

    try:
        response = ses_client.send_email(**email_content)
        
        status_code = 200
        body_resp = "The reminder has been notified successfully"
        
    except Exception as e:
        status_code = 500
        body_resp = {"message": f"Error: {str(e)}"}
    
    
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
        },
        "body": json.dumps(body_resp, default=str)
    }


def send_sms_reminder(phone_number, reminder):

    sns_client = boto3.client("sns", region_name=AWS_REGION)

    try:
        response = sns_client.publish(
            PhoneNumber='+' + phone_number,
            Message= reminder,
            Subject='Reminder'
        )
        status_code = 200
        body_resp = "The reminder has been notified successfully"
    
    except Exception as e:
        status_code = 500
        body_resp = {"message": f"Error: {str(e)}"}

    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
        },
        "body": json.dumps(body_resp, default=str)
    }
    
    
def sendReminder_handler(event, context):
    
    eventID = event['Records'][0]['eventID']
    dynamodb_steam_event = event['Records'][0]['eventName']
    
    print('=====================  SEND REMINDER LOG  ====================')
    print('EventID :' + eventID)
    print('DynamoDB Steam event: ' + dynamodb_steam_event)
    
    if dynamodb_steam_event == 'REMOVE':
    
        dynamodb_item       = event['Records'][0]['dynamodb']['OldImage']
        user_id             = dynamodb_item['UserID']['S']
        notification_type   = dynamodb_item['type']['S']
        reminder            = dynamodb_item['message']['S']
        
        if notification_type.lower() == "sms":
            resp = send_sms_reminder(user_id, reminder)
        else:
            resp = send_email_reminder(user_id, reminder)

        print('Reminder triggered:')
        print(dynamodb_item)
        print('Result:')
        print(resp)
    