# Query data on Amazon S3 using Amazon Athena

## OVERVIEW

The aim of this lab is query access logs for request by using Amazon Athena. Which supports analysis of S3 objects.
### What I will accomplish

This tutorial will guide me through the steps to query data on Amazon S3, allowing me to perform complex queries without setting up any servers or transforming data—simply by configuring the right data formats. I will learn:

- Understanding more about how AWS Athena works.
- Enabling Server Access logs for an S3 bucket

### Application architecture       

![](/hands_on_5/resources/hands_on_5_architecture.png)

## Amazon S3 server access logging

Server access logging provides detailed records for the requests that are made to an Amazon S3 bucket. Server access logs are useful for many applications. For example, access log information can be useful in security and access audits. This information can also help you learn about your customer base and understand your Amazon S3 bill.

**By default, Amazon S3 doesn't collect server access logs**. When you enable logging, Amazon S3 delivers access logs for a source bucket to a destination bucket (also known as a target bucket) that you choose. **The destination bucket must be in the same AWS Region and AWS account as the source bucket**.

### To enable server access logging

We can enable the S3 server access logging by using the Amazon S3 console, Amazon S3 REST API, AWS SDKs, AWS CLI, and Terraform use the following procedures:

- Using Terraform
    ```
        resource "aws_s3_bucket_logging" "example" {
            bucket = aws_s3_bucket.example.id

            target_bucket = aws_s3_bucket.log_bucket.id
            target_prefix = "log/"
        }
    ```
    > [!WARNING]
    > It's recommended enable a `lyfecycle` in order to delete the logs every specific time
        
- [Using the rest options](https://docs.aws.amazon.com/AmazonS3/latest/userguide/enable-server-access-logging.html#enable-server-logging)

### Resources

- [Enabling Amazon S3 server access logging](https://docs.aws.amazon.com/AmazonS3/latest/userguide/enable-server-access-logging.html)

## Athena

> [!NOTE]
> Before you run your first query, you need to set up a query result location in Amazon S3.

The following instructions show how we can query Amazon S3 server access logs in Amazon Athena:

1. Create a S3 Bucket which will have the logs to query.
1. Assign the previous S3 bucket created to Athena query result location
1. Create a Database Table that it represents the objects of the web static S3 bucket.
    - Athena query editor:
        ```CREATE DATABASE s3_access_logs_db```
    - Using Terraform:
        ```
            resource "aws_athena_database" "example" {
            name   = "database_name"
            bucket = aws_s3_bucket.example.id
            }
        ```
1. Create an external table which represents the bucket logs
    - *"Athena uses the Glue Data Catalog to store metadata about databases, tables, and views. All Athena tables are Glue tables. However, not all Glue tables work with Athena – you can create tables in Glue that won't be visible in Athena, and you can create tables that will be visible but won't work (for example cause runtime errors when you query them).
    Athena uses Glue Data Catalog for views, but the format is very specific to Athena, unlike regular tables which can be made interoperable with for example Spark"* 
    [Theo stackoverflow answer](https://stackoverflow.com/questions/64225241/create-athena-resources-with-terraform). 

    - Athena query editor:
        <details>
        <summary>
            Create a table schema in the database. Replace `s3_access_logs_db.mybucket_logs` with the name that you want to give to your table. The `STRING` and `BIGINT` data type values are the access log properties. You can query these properties in Athena. For `LOCATION`, enter the S3 bucket and prefix path as noted earlier
        </summary>
        ```
            CREATE EXTERNAL TABLE `s3_access_logs_db.mybucket_logs`(
                `bucketowner` STRING, 
                `bucket_name` STRING, 
                `requestdatetime` STRING, 
                `remoteip` STRING, 
                `requester` STRING, 
                `requestid` STRING, 
                `operation` STRING, 
                `key` STRING, 
                `request_uri` STRING, 
                `httpstatus` STRING, 
                `errorcode` STRING, 
                `bytessent` BIGINT, 
                `objectsize` BIGINT, 
                `totaltime` STRING, 
                `turnaroundtime` STRING, 
                `referrer` STRING, 
                `useragent` STRING, 
                `versionid` STRING, 
                `hostid` STRING, 
                `sigv` STRING, 
                `ciphersuite` STRING, 
                `authtype` STRING, 
                `endpoint` STRING, 
                `tlsversion` STRING,
                `accesspointarn` STRING,
                `aclrequired` STRING)
            ROW FORMAT SERDE 
            'org.apache.hadoop.hive.serde2.RegexSerDe' 
            WITH SERDEPROPERTIES ( 
            'input.regex'='([^ ]*) ([^ ]*) \\[(.*?)\\] ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) (\"[^\"]*\"|-) (-|[0-9]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) (\"[^\"]*\"|-) ([^ ]*)(?: ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*))?.*$') 
            STORED AS INPUTFORMAT 
            'org.apache.hadoop.mapred.TextInputFormat' 
            OUTPUTFORMAT 
            'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
            LOCATION
            's3://DOC-EXAMPLE-BUCKET1-logs/prefix/'
        ```
        </details>
    - Using Terraform:
        <details>
        <summary>
        `aws_athena_named_query` resource in Terraform allows you to define a named query, rather than execute an SQL statement directly. **Therefore it'll save it instead of of execute it**.

        ![](/hands_on_5/resources/query_saved.png)

        To run this query, we would typically **execute it manually** or trigger it through an AWS Lambda, Step Function, or another mechanism that supports running Athena queries.
        </summary>
        ```
            resource "aws_athena_named_query" "example_query" {
                name = "create_external_table_query"

                database = "s3_access_logs_db"  # Replace with your database name

                query = <<-EOT
                    CREATE EXTERNAL TABLE `mybucket_logs`(
                    `bucketowner` STRING, 
                    `bucket_name` STRING, 
                    `requestdatetime` STRING, 
                    -- ... (other columns)
                    `aclrequired` STRING)
                    ROW FORMAT SERDE 
                    'org.apache.hadoop.hive.serde2.RegexSerDe' 
                    WITH SERDEPROPERTIES ( 
                    'input.regex'='([^ ]*) ([^ ]*) \\[(.*?)\\] ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) (\"[^\"]*\"|-) (-|[0-9]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) (\"[^\"]*\"|-) ([^ ]*)(?: ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*))?.*$') 
                    STORED AS INPUTFORMAT 
                    'org.apache.hadoop.mapred.TextInputFormat' 
                    OUTPUTFORMAT 
                    'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
                    LOCATION
                    's3://DOC-EXAMPLE-BUCKET1-logs/prefix/'
                EOT
            }
        ```
1. Under Tables, choose Preview table next to our table name.
In the Results pane, we should see data from the server access logs, such as `bucketowner`, `bucket`, `requestdatetime`, and so on. This means that we successfully created the Athena table. We can now query the Amazon S3 server access logs.

### Resources

- [Using Amazon S3 server access logs](https://docs.aws.amazon.com/AmazonS3/latest/userguide/using-s3-access-logs-to-identify-requests.html)

## Lab result

**Query:** 
```
    SELECT request_uri, httpstatus, count(*) FROM "s3_access_logs_db" . "mybucket_logs"
    GROUP BY request_uri, httpstatus
```

**Query Result:**

![](/hands_on_5/resources/query_result.png)
