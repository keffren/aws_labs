# Create Continuous Delivery Pipeline [WIP]

## OVERVIEW

In this lab I will create an Reminder Serverless App.

The project idea and its highlights are provided by *Sam Williams* from *freecodecamp*: [How to Learn Serverless AWS by Building 7 Projects](https://www.freecodecamp.org/news/learn-serverless-aws-by-building-7-projects/)

### What I will accomplish

This project will teach me about Secondary Indexes in `Dynamo` as well as `Dynamo Time-To-Live`. I will also get to try either email automation with `Amazon Simple Email Service (SES)` or text messaging with `Simple Notification Service (SNS)`.

### Application architecture

![](https://www.freecodecamp.org/news/content/images/2022/08/ch4-reminder-app.drawio.png)

## AWS SERVICE: DYNAMODB

The idea for this app is that It can post a new reminder to the first API endpoint. This will write a new record in DynamoDB, but It will have added a global secondary index (GSI) to the table. This means that I can get a reminder by `id`, or you can query based on the `user`.

It will also have a `Time-To-Live` (TTL) which will allow you to trigger a Lambda at the time of the reminder as timestamp.

The table will look something like this:

| ID | USERID | TTL | TYPE | MESSAGE |
| --- | --- | --- | :---: | --- |
| 123 | test@gmail.com | 1702653459 | email | This is the email content |
| 456 | 34618096294 | 1702653459 | sms | This is the sms content |

The next resource is helpful to convert a date into Unix Timestamp:

- [Unix Timestamp converter](https://www.unixtimestamp.com/)

## AWS SERVICE: LAMBDA FUNCTION

The project is composed by the following lambda functions:

- **getReminder:** Retrieve a reminder using its `USERID` and `ID`
- **setReminder:** Create a reminder.
- **SendReminder:** Trigger the reminder and send the notification by its `TTL`

The next links helps to interact with dynamoDB through *boto3*:

- [Boto3 doc: Table Actions](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb/table/index.html#actions)
- [Boto3: DynamoDB actions](https://docs.aws.amazon.com/code-library/latest/ug/python_3_dynamodb_code_examples.html)

## AWS SERVICE: API GATEWAY

Amazon API GateWay creates REST API that:

- Are HTTP-based.
- Enable stateless client-server communication.
- **Expose the `lambda functions` as GET and POST HTTP methods.**

> As *getRemider()* method needs parameters, the `integration request type` must be `AWS_PROX`. Which means **Lambda proxy integration**. So the API Gateway directly passes the incoming request from the client as an event object to the Lambda function.

### GET Request Syntax

As I commented above, the GET method needs two parameters in order to retrieve the reminder. Those parameters are `userid` and `id`.

Request example: `https://1of8kqfct9.execute-api.eu-west-1.amazonaws.com/lab/reminder-app?userid=test@gmail.com&id=123`

## AWS SERVICES: DYNAMODB STREAM AND AWS LAMBDA TRIGGERS

Amazon DynamoDB is integrated with AWS Lambda so that it can create triggers—pieces of code that automatically **respond to events in DynamoDB Streams**. Through triggers, applications can be built to react to data modifications in DynamoDB tables. For this integration, **DynamoDB Streams must be enabled on a DynamoDB table.**

The AWS Lambda service polls the stream for new records (depends on stream view type) four times per second. When new stream records are available, the Lambda function is synchronously invoked.

**DynamoDB Streams contains all data modifications**, such as `Create`, `Modify`, and `Remove` actions, this can result in unwanted invocations of your archive Lambda function.

### How to enable DynamoDB Stream using Terraform

```
resource "aws_dynamodb_table" "example" {
  ...
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES" # Valid values are: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES
  ...
}
```
### The deletion of DynamoDB item is not instantaneous

The exact time of a dynamoDB item's deletion after it expires depends on the nature of the workload and the table's size. In the worst-case scenario, it may take up to a few days for the actual deletion event to occur, as explained in the [AWS documentation](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/howitworks-ttl.html).

However, this approach might not be the best for a reminder app. Nonetheless, the goal is to learn more about AWS.

## AWS SERVICE: SIMPLE EMAIL SERVICE (SES)

To prevent fraud and abuse, AWS applies certain restrictions to new Amazon SES accounts.

AWS places all new accounts in the **Amazon SES sandbox**. While SES account is in the sandbox, it has the following restrictions:

- It can only **send mail to verified email addresses and domains**, or to the Amazon SES mailbox simulator.
- It can send a maximum of 200 messages per 24-hour period.
- It can send a maximum of 1 message per second.
- **For sending authorization, neither you nor the delegate sender can send email to non-verified email addresses.**

For  more details: [AWS Documentation](https://docs.aws.amazon.com/ses/latest/dg/request-production-access.html?icmpid=docs_ses_console)

As this lab is for learning purposes, I won't set up the SES account for the production account. Therefore, the sender and receiver email addresses must be validated.

- [Creating an email address identity](https://docs.aws.amazon.com/ses/latest/dg/creating-identities.html#verify-email-addresses-procedure)
- [Boto3: send_email with SES](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ses/client/send_email.html)
- [SES Actions permissions](https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonses.html)

## AWS SERVICE: SIMPLE NOTIFICATION SERVICE (SNS)

Amazon SNS is a managed, highly-scalable messaging service by AWS which involves around topics, collection of messages. So, a client (*user | endpoint*) can subscribe to such a topic.

### Event Sources

Amazon SNS can receive event-driven notifications from many [AWS sources](https://docs.aws.amazon.com/sns/latest/dg/sns-event-sources.html)

### Destination Sources

Destinations are grouped as follows:

- Application-to-Application ([A2A](https://docs.aws.amazon.com/sns/latest/dg/sns-event-destinations.html#sns-event-destinations-a2a)) messaging
    - Includes Lambda, SQS, HTTP/s and more aws services.
- Application-to-Person ([A2P](https://docs.aws.amazon.com/sns/latest/dg/sns-event-destinations.html#sns-event-destinations-a2p)) notifications
    - Includes **SMS**, email and platform endpoints.

**AWS SNS operates under similar restrictions to AWS SES** with new accounts. Upon starting to use Amazon SNS for sending SMS messages, your AWS account is placed in the **SMS sandbox**. This means you can use all of the features of Amazon SNS, with the following limitations:

- **Sending SMS messages is restricted to verified destination phone numbers.**
- The maximum limit for verified destination phone numbers is 10.

For more information, refer to [SMS sandbox](https://docs.aws.amazon.com/sns/latest/dg/sns-sms-sandbox.html)

Hence, the phone numbers registered within the app must be validated.

- [Adding and verifying phone numbers in the SMS sandbox](https://docs.aws.amazon.com/sns/latest/dg/sns-sms-sandbox-verifying-phone-numbers.html)
- [Boto3: send sms](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/sns/client/publish.html)
- [SNS Actions permissions](https://docs.aws.amazon.com/sns/latest/dg/sns-access-policy-language-api-permissions-reference.html)
