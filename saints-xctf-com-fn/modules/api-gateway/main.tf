/**
 * Set up an API Gateway service for lambda functions.
 * Author: Andrew Jarombek
 * Date: 5/24/2020
 */

locals {
  env = var.prod ? "prodution" : "development"
}

resource "aws_api_gateway_rest_api" "saints-xctf-com-api" {
  name = "SaintsXCTFComAPI"
  description = "A REST API for AWS Lambda Functions used with saintsxctf.com"
}

# API Endpoints
# -------------
# /email/welcome
# /email/forgot-password

# Resource for the API path /email
resource "aws_api_gateway_resource" "saints-xctf-com-api-email-path" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-api.id
  parent_id = aws_api_gateway_rest_api.saints-xctf-com-api.root_resource_id
  path_part = "email"
}

# Resource for the API path /email/welcome
resource "aws_api_gateway_resource" "saints-xctf-com-api-welcome-path" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-api.id
  parent_id = aws_api_gateway_resource.saints-xctf-com-api-email-path.id
  path_part = "welcome"
}

# Resource for the API path /email/forgot-password
resource "aws_api_gateway_resource" "saints-xctf-com-api-forgot-password-path" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-api.id
  parent_id = aws_api_gateway_resource.saints-xctf-com-api-email-path.id
  path_part = "forgot-password"
}

resource "aws_api_gateway_method" "email-forgot-password-method" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-api.id
  resource_id = aws_api_gateway_resource.saints-xctf-com-api-forgot-password-path.id
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "email-forgot-password-method-response" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-api.id
  resource_id = aws_api_gateway_resource.saints-xctf-com-api-forgot-password-path.id

  http_method = aws_api_gateway_method.email-forgot-password-method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration" "email-forgot-password-integration" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-api.id
  resource_id = aws_api_gateway_resource.saints-xctf-com-api-forgot-password-path.id

  http_method = aws_api_gateway_method.email-forgot-password-method.http_method

  # Lambda functions can only be invoked via HTTP POST
  integration_http_method = "POST"

  type = "AWS"
  uri = var.lambda-function-invoke-arn

  request_templates = {
    "application/json" = file("${path.module}/request.vm")
  }
}

resource "aws_api_gateway_integration_response" "email-forgot-password-integration-response" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-api.id
  resource_id = aws_api_gateway_resource.saints-xctf-com-api-forgot-password-path.id

  http_method = aws_api_gateway_method.email-forgot-password-method.http_method
  status_code = aws_api_gateway_method_response.email-forgot-password-method-response.status_code

  response_templates = {
    "application/json" = file("${path.module}/response.vm")
  }

  depends_on = [
    aws_api_gateway_integration.email-forgot-password-integration
  ]
}

resource "aws_lambda_permission" "allow_api_gateway" {
  action = "lambda:InvokeFunction"
  function_name = var.lambda-function-name
  statement_id = "AllowExecutionFromApiGateway"
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.saints-xctf-com-api.execution_arn}/*/*/*"
}

resource "aws_api_gateway_deployment" "saints-xctf-com-api-deployment" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-api.id
  stage_name = local.env

  depends_on = [
    aws_api_gateway_integration.email-forgot-password-integration,
    aws_api_gateway_integration_response.email-forgot-password-integration-response
  ]
}