/**
 * Set up an API Gateway service for authorization lambda functions.
 * Author: Andrew Jarombek
 * Date: 5/29/2020
 */

locals {
  env = var.prod ? "prodution" : "development"
}

resource "aws_api_gateway_rest_api" "saints-xctf-com-auth" {
  name = "saints-xctf-com-fn"
  description = "A REST API for AWS Lambda Functions in the auth.saintsxctf.com domain"
}

resource "aws_api_gateway_deployment" "saints-xctf-com-fn-deployment" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-auth.id
  stage_name = local.env

  depends_on = [
    aws_api_gateway_integration.auth-authenticate-integration,
    aws_api_gateway_integration_response.auth-authenticate-integration-response
  ]
}

# API Endpoints
# -------------
# /authenticate
# /token

# ------------------------------------
# Resources for API path /authenticate
# ------------------------------------

resource "aws_api_gateway_resource" "saints-xctf-com-auth-authenticate-path" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-auth.id
  parent_id = aws_api_gateway_rest_api.saints-xctf-com-auth.root_resource_id
  path_part = "authenticate"
}

resource "aws_api_gateway_method" "auth-authenticate-method" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-auth.id
  resource_id = aws_api_gateway_resource.saints-xctf-com-auth-authenticate-path.id

  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_request_validator" "auth-authenticate-request-validator" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-auth.id
  validate_request_body = true
  validate_request_parameters = false
  name = "auth-authenticate-request-body-${local.env}"
}



resource "aws_api_gateway_integration" "auth-authenticate-integration" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-auth.id
  resource_id = aws_api_gateway_resource.saints-xctf-com-auth-authenticate-path.id

  http_method = aws_api_gateway_method.auth-authenticate-method.http_method

  # Lambda functions can only be invoked via HTTP POST
  integration_http_method = "POST"

  type = "AWS"
  uri = var.authenticate-lambda-invoke-arn

  request_templates = {
    "application/json" = file("${path.module}/authenticate-request.vm")
  }
}

resource "aws_api_gateway_method_response" "auth-authenticate-method-response" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-auth.id
  resource_id = aws_api_gateway_resource.saints-xctf-com-auth-authenticate-path.id

  http_method = aws_api_gateway_method.auth-authenticate-method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "auth-authenticate-integration-response" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-auth.id
  resource_id = aws_api_gateway_resource.saints-xctf-com-auth-authenticate-path.id

  http_method = aws_api_gateway_method.auth-authenticate-method.http_method
  status_code = aws_api_gateway_method_response.auth-authenticate-method-response.status_code

  response_templates = {
    "application/json" = file("${path.module}/authenticate-response.vm")
  }

  depends_on = [
    aws_api_gateway_integration.auth-authenticate-integration
  ]
}

resource "aws_lambda_permission" "allow_api_gateway_authenticate" {
  action = "lambda:InvokeFunction"
  function_name = var.authenticate-lambda-name
  statement_id = "AllowExecutionFromApiGateway"
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.saints-xctf-com-auth.execution_arn}/*/*/*"
}

# -----------------------------
# Resources for API path /token
# -----------------------------

resource "aws_api_gateway_resource" "saints-xctf-com-auth-token-path" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-auth.id
  parent_id = aws_api_gateway_rest_api.saints-xctf-com-auth.root_resource_id
  path_part = "token"
}

resource "aws_api_gateway_method" "auth-token-method" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-auth.id
  resource_id = aws_api_gateway_resource.saints-xctf-com-auth-token-path.id

  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_request_validator" "auth-token-request-validator" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-auth.id
  validate_request_body = true
  validate_request_parameters = false
  name = "auth-token-request-body-${local.env}"
}

resource "aws_api_gateway_method_response" "auth-token-method-response" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-auth.id
  resource_id = aws_api_gateway_resource.saints-xctf-com-auth-token-path.id

  http_method = aws_api_gateway_method.auth-authenticate-method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration" "auth-token-integration" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-auth.id
  resource_id = aws_api_gateway_resource.saints-xctf-com-auth-token-path.id

  http_method = aws_api_gateway_method.auth-token-method.http_method

  # Lambda functions can only be invoked via HTTP POST
  integration_http_method = "POST"

  type = "AWS"
  uri = var.token-lambda-invoke-arn

  request_templates = {
    "application/json" = file("${path.module}/token-request.vm")
  }
}

resource "aws_api_gateway_integration_response" "auth-token-integration-response" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-auth.id
  resource_id = aws_api_gateway_resource.saints-xctf-com-auth-token-path.id

  http_method = aws_api_gateway_method.auth-token-method.http_method
  status_code = aws_api_gateway_method_response.auth-token-method-response.status_code

  response_templates = {
    "application/json" = file("${path.module}/token-response.vm")
  }

  depends_on = [
    aws_api_gateway_integration.auth-token-integration
  ]
}

resource "aws_lambda_permission" "allow_api_gateway_token" {
  action = "lambda:InvokeFunction"
  function_name = var.token-lambda-name
  statement_id = "AllowExecutionFromApiGateway"
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.saints-xctf-com-auth.execution_arn}/*/*/*"
}
