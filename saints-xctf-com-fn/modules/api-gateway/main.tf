/**
 * Set up an API Gateway service for lambda functions.
 * Author: Andrew Jarombek
 * Date: 5/24/2020
 */

resource "aws_api_gateway_rest_api" "saints-xctf-com-api" {
  name = "SaintsXCTFComAPI"
  description = "A REST API for AWS Lambda Functions used with saintsxctf.com"
}

# API Endpoints
# -------------
# /email/welcome
# /email/forgot-password

# Resource for the API path /email
resource "aws_api_gateway_resource" "jarombek-com-api-email-path" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-api.id
  parent_id = aws_api_gateway_rest_api.saints-xctf-com-api.root_resource_id
  path_part = "email"
}

# Resource for the API path /email/welcome
resource "aws_api_gateway_resource" "jarombek-com-api-welcome-path" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-api.id
  parent_id = aws_api_gateway_resource.jarombek-com-api-email-path.id
  path_part = "welcome"
}

# Resource for the API path /email/forgot-password
resource "aws_api_gateway_resource" "jarombek-com-api-forgot-password-path" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-api.id
  parent_id = aws_api_gateway_resource.jarombek-com-api-email-path.id
  path_part = "forgot-password"
}

resource "aws_api_gateway_method" "email-forgot-password-method" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-api.id
  resource_id = aws_api_gateway_resource.jarombek-com-api-forgot-password-path.id
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "email-forgot-password-integration" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-api.id
  resource_id = aws_api_gateway_resource.jarombek-com-api-forgot-password-path.id
  http_method = "POST"
  type = "AWS_PROXY"
  uri = var.lambda-function-invoke-arn
}

resource "aws_lambda_permission" "allow_api_gateway" {
  action = "lambda:InvokeFunction"
  function_name = var.lambda-function-name
  statement_id = "AllowExecutionFromApiGateway"
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.saints-xctf-com-api.execution_arn}/*/*/*"
}