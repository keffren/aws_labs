# Create Continuous Delivery Pipeline [WIP]

## OVERVIEW

In this lab I will create an Reminder Serverless App.

The tutorial project is provided by *Sam Williams* from *freecodecamp*: [How to Learn Serverless AWS by Building 7 Projects](https://www.freecodecamp.org/news/learn-serverless-aws-by-building-7-projects/)

### What I will accomplish

This project will teach me about Secondary Indexes in `Dynamo` as well as `Dynamo Time-To-Live`. I will also get to try either email automation with `Amazon Simple Email Service (SES)` or text messaging with `Simple Notification Service (SNS)`.

### Application architecture

![](https://www.freecodecamp.org/news/content/images/2022/08/ch4-reminder-app.drawio.png)

## AWS SERVICE: DYNAMODB

The idea for this app is that It can post a new reminder to the first API endpoint. This will write a new record in DynamoDB, but It will have added a global secondary index (GSI) to the table. This means that I can get a reminder by `id`, or you can query based on the `user`.

It will also have a `Time-To-Live` (TTL) which will allow you to trigger a Lambda at the time of the reminder as timestamp. The code for set reminders will looks pretty similar to the previous project.

The table will look something like this:

| ID | USERID | TTL | TYPE | MESSAGE |
| --- | --- | --- | :---: | --- |
| 123 | test@gmail.com | 1702653459 | email | This is the email content |
| 456 | 34618096294 | 1702653459 | sms | This is the sms content |

The next resource is helpful to convert a date into Unix Timestamp:

- [Unix Timestamp converter](https://www.unixtimestamp.com/)

## AWS SERVICE: LAMBDA FUNCTION

- [Boto3 doc: Table Actions](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb/table/index.html#actions)
-[Boto3: DynamoDB actions](https://docs.aws.amazon.com/code-library/latest/ug/python_3_dynamodb_code_examples.html)