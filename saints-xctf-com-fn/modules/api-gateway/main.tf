/**
 * Set up an API Gateway service for lambda functions.
 * Author: Andrew Jarombek
 * Date: 5/24/2020
 */

locals {
  env = var.prod ? "prodution" : "development"
  domain_name = var.prod ? "fn.saintsxctf.com" : "dev.fn.saintsxctf.com"
  cert = var.prod ? "*.saintsxctf.com" : "*.fn.saintsxctf.com"
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_route53_zone" "saints-xctf-wildcard-zone" {
  name = "saintsxctf.com."
  private_zone = false
}

data "aws_acm_certificate" "saints-xctf-wildcard-cert" {
  domain = local.cert
  statuses = ["ISSUED"]
}

data "aws_lambda_function" "authorizer" {
  function_name = "SaintsXCTFAuthorizer${upper(local.env)}"
}

data "template_file" "api-gateway-auth-policy-file" {
  template = file("${path.module}/api-gateway-auth-policy.json")

  vars = {
    lambda_arn = data.aws_lambda_function.authorizer.invoke_arn
  }
}

#----------------------------------
# New AWS Resources for API Gateway
#----------------------------------

resource "aws_api_gateway_rest_api" "saints-xctf-com-fn" {
  name = "saints-xctf-com-fn"
  description = "A REST API for AWS Lambda Functions in the fn.saintsxctf.com domain"
}

resource "aws_api_gateway_authorizer" "saints-xctf-com-fn-authorizer" {
  type = "TOKEN"
  name = "saints-xctf-com-fn-auth"
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  authorizer_uri = data.aws_lambda_function.authorizer.invoke_arn
}

resource "aws_iam_role" "auth-invocation-role" {
  name = "api-gateway-auth-role"
  path = "/saints-xctf-com/"
  assume_role_policy = file("${path.module}/api-gateway-auth-role.json")
  description = "IAM Role for invoking an authentication Lambda function from API Gateway"
}

resource "aws_iam_policy" "auth-invocation-policy" {
  name = "api-gateway-auth-policy"
  path = "/saints-xctf-com/"
  policy = data.template_file.api-gateway-auth-policy-file.rendered
  description = "IAM Policy for invoking an authentication Lambda function from API Gateway"
}

resource "aws_iam_role_policy_attachment" "auth-invocation-role-policy-attachment" {
  policy_arn = aws_iam_policy.auth-invocation-policy.arn
  role = aws_iam_role.auth-invocation-role.name
}

resource "aws_api_gateway_domain_name" "saints-xctf-com-fn-domain" {
  domain_name = local.domain_name
  certificate_arn = data.aws_acm_certificate.saints-xctf-wildcard-cert.arn
}

resource "aws_route53_record" "saints-xctf-com-fn-record" {
  name = aws_api_gateway_domain_name.saints-xctf-com-fn-domain.domain_name
  type = "A"
  zone_id = data.aws_route53_zone.saints-xctf-wildcard-zone.id

  alias {
    evaluate_target_health = true
    name = aws_api_gateway_domain_name.saints-xctf-com-fn-domain.cloudfront_domain_name
    zone_id = aws_api_gateway_domain_name.saints-xctf-com-fn-domain.cloudfront_zone_id
  }
}

# API Endpoints
# -------------
# /email/welcome
# /email/forgot-password

# Resource for the API path /email
resource "aws_api_gateway_resource" "saints-xctf-com-fn-email-path" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  parent_id = aws_api_gateway_rest_api.saints-xctf-com-fn.root_resource_id
  path_part = "email"
}

# Resource for the API path /email/welcome
resource "aws_api_gateway_resource" "saints-xctf-com-fn-welcome-path" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  parent_id = aws_api_gateway_resource.saints-xctf-com-fn-email-path.id
  path_part = "welcome"
}

# Resource for the API path /email/forgot-password
resource "aws_api_gateway_resource" "saints-xctf-com-fn-forgot-password-path" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  parent_id = aws_api_gateway_resource.saints-xctf-com-fn-email-path.id
  path_part = "forgot-password"
}

resource "aws_api_gateway_method" "email-forgot-password-method" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  resource_id = aws_api_gateway_resource.saints-xctf-com-fn-forgot-password-path.id
  request_validator_id = aws_api_gateway_request_validator.email-forgot-password-request-validator.id

  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_request_validator" "email-forgot-password-request-validator" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  validate_request_body = true
  validate_request_parameters = false
  name = "email-forgot-password-request-body-${local.env}"
}

resource "aws_api_gateway_method_response" "email-forgot-password-method-response" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  resource_id = aws_api_gateway_resource.saints-xctf-com-fn-forgot-password-path.id

  http_method = aws_api_gateway_method.email-forgot-password-method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration" "email-forgot-password-integration" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  resource_id = aws_api_gateway_resource.saints-xctf-com-fn-forgot-password-path.id

  http_method = aws_api_gateway_method.email-forgot-password-method.http_method

  # Lambda functions can only be invoked via HTTP POST
  integration_http_method = "POST"

  type = "AWS"
  uri = var.email-lambda-invoke-arn

  request_templates = {
    "application/json" = file("${path.module}/request.vm")
  }
}

resource "aws_api_gateway_integration_response" "email-forgot-password-integration-response" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  resource_id = aws_api_gateway_resource.saints-xctf-com-fn-forgot-password-path.id

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
  function_name = var.email-lambda-name
  statement_id = "AllowExecutionFromApiGateway"
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.saints-xctf-com-fn.execution_arn}/*/*/*"
}

resource "aws_api_gateway_deployment" "saints-xctf-com-fn-deployment" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  stage_name = local.env

  depends_on = [
    aws_api_gateway_integration.email-forgot-password-integration,
    aws_api_gateway_integration_response.email-forgot-password-integration-response
  ]
}