variable "aws_region" {
  type     = string
  default = "us-east-1"
}

variable "query_result_bucket_location" {
  type = string
  default = "athena-myresume-web-logs"
}