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

# API Endpoints
# -------------
# /authenticate
# /token

# Resource for the API path /authenticate
resource "aws_api_gateway_resource" "saints-xctf-com-auth-authenticate-path" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-auth.id
  parent_id = aws_api_gateway_rest_api.saints-xctf-com-auth.root_resource_id
  path_part = "authenticate"
}

# Resource for the API path /token
resource "aws_api_gateway_resource" "saints-xctf-com-auth-token-path" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-auth.id
  parent_id = aws_api_gateway_rest_api.saints-xctf-com-auth.root_resource_id
  path_part = "token"
}

resource "aws_api_gateway_method" "auth-authenticate-method" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-auth.id
  resource_id = aws_api_gateway_resource.saints-xctf-com-auth-authenticate-path.id

  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "auth-token-method" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-auth.id
  resource_id = aws_api_gateway_resource.saints-xctf-com-auth-token-path.id

  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_request_validator" "auth-authenticate-request-validator" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-auth.id
  validate_request_body = true
  validate_request_parameters = false
  name = "auth-authenticate-request-body-${local.env}"
}

resource "aws_api_gateway_request_validator" "auth-token-request-validator" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-auth.id
  validate_request_body = true
  validate_request_parameters = false
  name = "auth-token-request-body-${local.env}"
}

resource "aws_api_gateway_method_response" "auth-authenticate-method-response" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-auth.id
  resource_id = aws_api_gateway_resource.saints-xctf-com-auth-authenticate-path.id

  http_method = aws_api_gateway_method.auth-authenticate-method.http_method
  status_code = "200"
}

resource "aws_api_gateway_method_response" "auth-token-method-response" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-auth.id
  resource_id = aws_api_gateway_resource.saints-xctf-com-auth-token-path.id

  http_method = aws_api_gateway_method.auth-authenticate-method.http_method
  status_code = "200"
}
