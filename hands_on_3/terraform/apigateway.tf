# ===============================================  CREATE THE API
resource "aws_api_gateway_rest_api" "reminder_app" {
    name = "Reminder-App-API"
    description = "Reminder App API Gateway"

    endpoint_configuration {
        types = ["EDGE"]
    }

    tags = {
        Lab = "Hands on n3"
        Terraform = "true"
    }
}

resource "aws_api_gateway_resource" "reminder_app" {
    rest_api_id = aws_api_gateway_rest_api.reminder_app.id
    parent_id = aws_api_gateway_rest_api.reminder_app.root_resource_id
    path_part = "reminder-app"
}

# ===============================================  CREATE GET METHOD WITH LAMBDA INTEGRATION
resource "aws_api_gateway_method" "get_method_request" {
    rest_api_id = aws_api_gateway_rest_api.reminder_app.id
    resource_id = aws_api_gateway_resource.reminder_app.id
    http_method = "GET"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_integration_request" {
    rest_api_id = aws_api_gateway_rest_api.reminder_app.id
    resource_id = aws_api_gateway_resource.reminder_app.id
    http_method = aws_api_gateway_method.get_method_request.http_method
    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = aws_lambda_function.getReminder.invoke_arn
}

resource "aws_api_gateway_method_response" "get_method_response" {
    rest_api_id = aws_api_gateway_rest_api.reminder_app.id
    resource_id = aws_api_gateway_resource.reminder_app.id
    http_method = aws_api_gateway_method.get_method_request.http_method
    status_code = "200"
}

resource "aws_api_gateway_integration_response" "get_integration_response" {
    rest_api_id = aws_api_gateway_rest_api.reminder_app.id
    resource_id = aws_api_gateway_resource.reminder_app.id
    http_method = aws_api_gateway_method.get_method_request.http_method
    status_code = aws_api_gateway_method_response.get_method_response.status_code

    depends_on = [
        aws_api_gateway_method.get_method_request,
        aws_api_gateway_integration.get_integration_request
    ]
}

# Granting Lambda Permissions to the GET API Gateway method
resource "aws_lambda_permission" "apigw_invoke_get_reminder_lambda" {
    statement_id  = "AllowAPIGatewayInvoke"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.getReminder.function_name
    principal     = "apigateway.amazonaws.com"
    source_arn    = "${aws_api_gateway_rest_api.reminder_app.execution_arn}/*/*/*"
} 

# ===============================================   CREATE POST METHOD WITH LAMBDA INTEGRATION
resource "aws_api_gateway_method" "post_method_request" {
    rest_api_id = aws_api_gateway_rest_api.reminder_app.id
    resource_id = aws_api_gateway_resource.reminder_app.id
    http_method = "POST"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_integration_request" {
    rest_api_id = aws_api_gateway_rest_api.reminder_app.id
    resource_id = aws_api_gateway_resource.reminder_app.id
    http_method = aws_api_gateway_method.post_method_request.http_method
    integration_http_method = "POST"
    type = "AWS"
    uri = aws_lambda_function.setReminder.invoke_arn
}

resource "aws_api_gateway_method_response" "post_method_response" {
    rest_api_id = aws_api_gateway_rest_api.reminder_app.id
    resource_id = aws_api_gateway_resource.reminder_app.id
    http_method = aws_api_gateway_method.post_method_request.http_method
    status_code = "200"

}

resource "aws_api_gateway_integration_response" "post_integration_response" {
    rest_api_id = aws_api_gateway_rest_api.reminder_app.id
    resource_id = aws_api_gateway_resource.reminder_app.id
    http_method = aws_api_gateway_method.post_method_request.http_method
    status_code = aws_api_gateway_method_response.post_method_response.status_code

    depends_on = [
        aws_api_gateway_method.post_method_request,
        aws_api_gateway_integration.post_integration_request
    ]
}

# Granting Lambda Permissions to the POST API Gateway method
resource "aws_lambda_permission" "apigw_invoke_set_reminder_lambda" {
    statement_id  = "AllowAPIGatewayInvoke"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.setReminder.function_name
    principal     = "apigateway.amazonaws.com"
    source_arn    = "${aws_api_gateway_rest_api.reminder_app.execution_arn}/*/*/*"
} 

# ===============================================   DEPLOY API
resource "aws_api_gateway_deployment" "deployment" {
    rest_api_id = aws_api_gateway_rest_api.reminder_app.id

    triggers = {
        # NOTE: The configuration below will satisfy ordering considerations,
        #       but not pick up all future REST API changes. More advanced patterns
        #       are possible, such as using the filesha1() function against the
        #       Terraform configuration file(s) or removing the .id references to
        #       calculate a hash against whole resources. Be aware that using whole
        #       resources will show a difference after the initial implementation.
        #       It will stabilize to only change when resources change afterwards.
        redeployment = sha1(jsonencode([
            aws_api_gateway_resource.reminder_app.id,
            aws_api_gateway_method.post_method_request.id,
            aws_api_gateway_method.get_method_request.id,
            aws_api_gateway_integration.get_integration_request.id,
            aws_api_gateway_integration.post_integration_request.id,
        ]))
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_api_gateway_stage" "dev" {
    deployment_id = aws_api_gateway_deployment.deployment.id
    rest_api_id   = aws_api_gateway_rest_api.reminder_app.id
    stage_name    = "lab"
}