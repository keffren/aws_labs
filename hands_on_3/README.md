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
