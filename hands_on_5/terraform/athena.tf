# Declare the bucket which contains the logs to query
resource "aws_athena_database" "s3_access_logs_bucket" {
  name   = "s3_access_logs_db"
  bucket = aws_s3_bucket.athena_query_logs.id
}

resource "aws_athena_named_query" "example_query" {
  name = "create_external_table_query"

  database = "s3_access_logs_db"

  query = <<-EOT
    CREATE EXTERNAL TABLE `mybucket_logs`(
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
      's3://mateodev.cloud-server-access-logs/log/'
  EOT
}