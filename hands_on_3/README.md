# Create Continuous Delivery Pipeline

## OVERVIEW

In this lab I will create an Reminder Serverless App.

The tutorial project is provided by *Sam Williams* from *freecodecamp*: [How to Learn Serverless AWS by Building 7 Projects](https://www.freecodecamp.org/news/learn-serverless-aws-by-building-7-projects/)

### What I will accomplish

This project will teach me about Secondary Indexes in `Dynamo` as well as `Dynamo Time-To-Live`. I will also get to try either email automation with `Amazon Simple Email Service (SES)` or text messaging with `Simple Notification Service (SNS)`.

### Application architecture

![](https://www.freecodecamp.org/news/content/images/2022/08/ch4-reminder-app.drawio.png)

## AWS SERVICE: DYNAMODB

The idea for this app is that It can post a new reminder to the first API endpoint. This will write a new record in DynamoDB, but It will have added a global secondary index (GSI) to the table. This means that I can get a reminder by `id`, or you can query based on the `user`.

It will also have a `Time-To-Live` (TTL) which will allow you to trigger a Lambda at the time of the reminder. The code for set reminders will looks pretty similar to the previous project.

The table will look something like this:

| ID | USERID | TTL | NOTIFICATIONTYPE | MESSAGE |
| --- | --- | --- | :---: | --- |
| 123 | test@gmail.com | 1648277828 | email | This is the email content |
| 456 | 34618096294 | 1648842828 | sms | This is the sms content |

Two things to note with `TTL`:

- Make sure that this is the Unix timestamp for the deletion date – but in seconds: 
```new Date('october 20 2022').getTime()``` will be in milliseconds, so just divide by 1000.
- The record will be deleted within a 15-minute window after your TTL so don't panic if it's been 5 minutes and the record hasn't been deleted yet.