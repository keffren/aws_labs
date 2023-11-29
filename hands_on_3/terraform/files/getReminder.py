import json
import boto3

def getReminder_handler(event, context):
    
    table_name = "reminders"
    hash_key = event["UserID"]
    sort_key = event["id"]
    
    #Connect to DynamoDB
    dynamodb = boto3.resource('dynamodb', region_name='eu-west-1')
    
    #Retrieve the item
    table = dynamodb.Table(table_name)
    
    '''
    Query Alternative
    item = table.query(
        KeyConditionExpression=Key('UserID').eq(hash_key) & Key('id').eq(123)
    )
    '''
    
    response = table.get_item(
        Key={
            'UserID': hash_key,
            'id': sort_key
        }
    )

    # Check If there is matching item
    if "Item" in response:
        statusCode = 200
        body_resp = response['Item']
    else:
        statusCode = 401
        body_resp = json.dumps({
                "message": "There is not match "
        })
    
    return {
        "statusCode": statusCode,
        "headers": {
            "Content-Type": "application/json",
        },
        "body": body_resp
    }
