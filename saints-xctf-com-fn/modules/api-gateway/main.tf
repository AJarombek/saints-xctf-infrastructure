/**
 * Set up an API Gateway service for lambda functions.
 * Author: Andrew Jarombek
 * Date: 5/24/2020
 */

locals {
  env = var.prod ? "production" : "development"
  env_short = var.prod ? "prod" : "dev"
  env_suffix = var.prod ? "" : "-dev"
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
  function_name = "SaintsXCTFAuthorizer${upper(local.env_short)}"
}

data "template_file" "api-gateway-auth-policy-file" {
  template = file("${path.module}/api-gateway-auth-policy.json")

  vars = {
    lambda_arn = data.aws_lambda_function.authorizer.arn
  }
}

#----------------------------------
# New AWS Resources for API Gateway
#----------------------------------

resource "aws_api_gateway_rest_api" "saints-xctf-com-fn" {
  name = "saints-xctf-com-fn${local.env_suffix}"
  description = "A REST API for AWS Lambda Functions in the fn.saintsxctf.com domain"

  binary_media_types = []
  disable_execute_api_endpoint = true
}

resource "aws_api_gateway_deployment" "saints-xctf-com-fn-deployment" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id

  depends_on = [
    module.api-gateway-forgot-password-endpoint,
    module.api-gateway-activation-code-endpoint,
    module.api-gateway-report-endpoint,
    module.api-gateway-welcome-endpoint,
    module.api-gateway-uasset-group-endpoint,
    module.api-gateway-uasset-user-endpoint
  ]
}

resource "aws_api_gateway_stage" "saints-xctf-com-fn-stage" {
  deployment_id = aws_api_gateway_deployment.saints-xctf-com-fn-deployment.id
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  stage_name = local.env
  xray_tracing_enabled = var.enable-xray-tracing

  tags = {
    Name = "saints-xctf-com-fn-api"
    Application = "saints-xctf"
    Environment = local.env
  }
}

resource "aws_api_gateway_method_settings" "saints-xctf-com-fn-method-settings" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  stage_name = aws_api_gateway_stage.saints-xctf-com-fn-stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level = "INFO"
  }
}

resource "aws_api_gateway_authorizer" "saints-xctf-com-fn-authorizer" {
  type = "TOKEN"
  name = "saints-xctf-com-fn-auth"
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  authorizer_uri = data.aws_lambda_function.authorizer.invoke_arn
  identity_source = "method.request.header.Authorization"
  authorizer_credentials = aws_iam_role.auth-invocation-role.arn
}

resource "aws_iam_role" "auth-invocation-role" {
  name = "api-gateway-auth-role-${local.env_short}"
  path = "/saints-xctf-com/"
  assume_role_policy = file("${path.module}/api-gateway-auth-role.json")
  description = "IAM Role for invoking an authentication Lambda function from API Gateway in the ${local.env} environment"
}

resource "aws_iam_policy" "auth-invocation-policy" {
  name = "api-gateway-auth-policy-${local.env_short}"
  path = "/saints-xctf-com/"
  policy = data.template_file.api-gateway-auth-policy-file.rendered
  description = "IAM Policy for invoking an authentication Lambda function from API Gateway in the ${local.env} environment"
}

resource "aws_iam_role_policy_attachment" "auth-invocation-role-policy-attachment" {
  policy_arn = aws_iam_policy.auth-invocation-policy.arn
  role = aws_iam_role.auth-invocation-role.name
}

resource "aws_api_gateway_domain_name" "saints-xctf-com-fn-domain" {
  domain_name = local.domain_name
  certificate_arn = data.aws_acm_certificate.saints-xctf-wildcard-cert.arn
}

resource "aws_api_gateway_base_path_mapping" "saints-xctf-com-fn-base" {
  api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  stage_name = aws_api_gateway_stage.saints-xctf-com-fn-stage.stage_name
  domain_name = aws_api_gateway_domain_name.saints-xctf-com-fn-domain.domain_name
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

resource "aws_lambda_permission" "allow_api_gateway-authorizer" {
  action = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.authorizer.function_name
  statement_id = "AllowExecutionFromApiGateway"
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.saints-xctf-com-fn.execution_arn}/*/*/*"
}

# API Endpoints
# -------------
# /email/welcome
# /email/report
# /email/forgot-password
# /email/activation-code
# /uasset/user
# /uasset/group
# /uasset/signed-url/user
# /uasset/signed-url/group

# Resource for the API path /email
resource "aws_api_gateway_resource" "saints-xctf-com-fn-email-path" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  parent_id = aws_api_gateway_rest_api.saints-xctf-com-fn.root_resource_id
  path_part = "email"
}

# No difficult time will last forever, even if it feels like it at times.
# You are so strong and there is so much love & support for you.
# I will.

# Resource for the API path /uasset
resource "aws_api_gateway_resource" "saints-xctf-com-fn-uasset-path" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  parent_id = aws_api_gateway_rest_api.saints-xctf-com-fn.root_resource_id
  path_part = "uasset"
}

# Resource for the API path /uasset/signed-url
resource "aws_api_gateway_resource" "saints-xctf-com-fn-uasset-signed-url-path" {
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  parent_id = aws_api_gateway_resource.saints-xctf-com-fn-uasset-path.id
  path_part = "signed-url"
}

/* POST /email/forgot-password */

module "api-gateway-forgot-password-endpoint" {
  source = "github.com/ajarombek/cloud-modules//terraform-modules/api-gateway-endpoint?ref=v0.2.8"

  # Mandatory arguments
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  parent_path_id = aws_api_gateway_resource.saints-xctf-com-fn-email-path.id
  path = "forgot-password"
  request_validator_name = "email-forgot-password-request-body-${local.env}"

  request_templates = {
    "application/json" = file("${path.module}/email/forgot-password/request.vm")
  }

  response_template = file("${path.module}/email/forgot-password/response.vm")

  lambda_invoke_arn = var.email-forgot-password-lambda-invoke-arn

  # Optional arguments
  http_method = "POST"
  validate_request_body = true
  validate_request_parameters = false
  content_handling = null
  authorization = "NONE"
  authorizer_id = null
}

resource "aws_lambda_permission" "allow_api_gateway" {
  action = "lambda:InvokeFunction"
  function_name = var.email-forgot-password-lambda-name
  statement_id = "AllowExecutionFromApiGateway"
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.saints-xctf-com-fn.execution_arn}/*/*/*"
}

/* POST /email/activation-code */

module "api-gateway-activation-code-endpoint" {
  source = "github.com/ajarombek/cloud-modules//terraform-modules/api-gateway-endpoint?ref=v0.2.8"

  # Mandatory arguments
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  parent_path_id = aws_api_gateway_resource.saints-xctf-com-fn-email-path.id
  path = "activation-code"
  request_validator_name = "email-activation-code-request-body-${local.env}"

  request_templates = {
    "application/json" = file("${path.module}/email/activation-code/request.vm")
  }

  response_template = file("${path.module}/email/activation-code/response.vm")

  lambda_invoke_arn = var.email-activation-code-lambda-invoke-arn

  # Optional arguments
  http_method = "POST"
  validate_request_body = true
  validate_request_parameters = false
  content_handling = null
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.saints-xctf-com-fn-authorizer.id
}

resource "aws_lambda_permission" "allow-api-gateway-email-activation-code" {
  action = "lambda:InvokeFunction"
  function_name = var.email-activation-code-lambda-name
  statement_id = "AllowExecutionFromApiGateway"
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.saints-xctf-com-fn.execution_arn}/*/*/*"
}

/* POST /email/report */

module "api-gateway-report-endpoint" {
  source = "github.com/ajarombek/cloud-modules//terraform-modules/api-gateway-endpoint?ref=v0.2.8"

  # Mandatory arguments
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  parent_path_id = aws_api_gateway_resource.saints-xctf-com-fn-email-path.id
  path = "report"
  request_validator_name = "email-report-request-body-${local.env}"

  request_templates = {
    "application/json" = file("${path.module}/email/report/request.vm")
  }

  response_template = file("${path.module}/email/report/response.vm")

  lambda_invoke_arn = var.email-report-lambda-invoke-arn

  # Optional arguments
  http_method = "POST"
  validate_request_body = true
  validate_request_parameters = false
  content_handling = null
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.saints-xctf-com-fn-authorizer.id
}

resource "aws_lambda_permission" "allow-api-gateway-email-report" {
  action = "lambda:InvokeFunction"
  function_name = var.email-report-lambda-name
  statement_id = "AllowExecutionFromApiGateway"
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.saints-xctf-com-fn.execution_arn}/*/*/*"
}

/* POST /email/welcome */

module "api-gateway-welcome-endpoint" {
  source = "github.com/ajarombek/cloud-modules//terraform-modules/api-gateway-endpoint?ref=v0.2.8"

  # Mandatory arguments
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  parent_path_id = aws_api_gateway_resource.saints-xctf-com-fn-email-path.id
  path = "welcome"
  request_validator_name = "email-welcome-request-body-${local.env}"

  request_templates = {
    "application/json" = file("${path.module}/email/welcome/request.vm")
  }

  response_template = file("${path.module}/email/welcome/response.vm")

  lambda_invoke_arn = var.email-welcome-lambda-invoke-arn

  # Optional arguments
  http_method = "POST"
  validate_request_body = true
  validate_request_parameters = false
  content_handling = null
  authorization = "NONE"
  authorizer_id = null
}

resource "aws_lambda_permission" "allow-api-gateway-email-welcome" {
  action = "lambda:InvokeFunction"
  function_name = var.email-welcome-lambda-name
  statement_id = "AllowExecutionFromApiGateway"
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.saints-xctf-com-fn.execution_arn}/*/*/*"
}

/* POST /uasset/user */

module "api-gateway-uasset-user-endpoint" {
  source = "github.com/ajarombek/cloud-modules//terraform-modules/api-gateway-endpoint?ref=v0.2.8"

  # Mandatory arguments
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  parent_path_id = aws_api_gateway_resource.saints-xctf-com-fn-uasset-path.id
  path = "user"
  request_validator_name = "uasset-user-request-body-${local.env}"

  request_templates = {
    "application/json" = file("${path.module}/uasset/user/request.vm")
  }

  response_template = file("${path.module}/uasset/user/response.vm")

  lambda_invoke_arn = var.uasset-user-lambda-invoke-arn

  # Optional arguments
  http_method = "POST"
  validate_request_body = true
  validate_request_parameters = false
  content_handling = "CONVERT_TO_TEXT"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.saints-xctf-com-fn-authorizer.id
}

resource "aws_lambda_permission" "allow-api-gateway-uasset-user" {
  action = "lambda:InvokeFunction"
  function_name = var.uasset-user-lambda-name
  statement_id = "AllowExecutionFromApiGateway"
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.saints-xctf-com-fn.execution_arn}/*/*/*"
}

/* POST /uasset/group */

module "api-gateway-uasset-group-endpoint" {
  source = "github.com/ajarombek/cloud-modules//terraform-modules/api-gateway-endpoint?ref=v0.2.8"

  # Mandatory arguments
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  parent_path_id = aws_api_gateway_resource.saints-xctf-com-fn-uasset-path.id
  path = "group"
  request_validator_name = "uasset-group-request-body-${local.env}"

  request_templates = {
    "application/json" = file("${path.module}/uasset/group/request.vm")
  }

  response_template = file("${path.module}/uasset/group/response.vm")

  lambda_invoke_arn = var.uasset-group-lambda-invoke-arn

  # Optional arguments
  http_method = "POST"
  validate_request_body = true
  validate_request_parameters = false
  content_handling = "CONVERT_TO_TEXT"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.saints-xctf-com-fn-authorizer.id
}

resource "aws_lambda_permission" "allow-api-gateway-uasset-group" {
  action = "lambda:InvokeFunction"
  function_name = var.uasset-group-lambda-name
  statement_id = "AllowExecutionFromApiGateway"
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.saints-xctf-com-fn.execution_arn}/*/*/*"
}

/* POST /uasset/signed-url/user */

module "api-gateway-uasset-signed-url-user-endpoint" {
  source = "github.com/ajarombek/cloud-modules//terraform-modules/api-gateway-endpoint?ref=v0.2.8"

  # Mandatory arguments
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  parent_path_id = aws_api_gateway_resource.saints-xctf-com-fn-uasset-signed-url-path.id
  path = "user"
  request_validator_name = "uasset-signed-url-user-request-body-${local.env}"

  request_templates = {
    "application/json" = file("${path.module}/uasset/signed-url/user/request.vm")
  }

  response_template = file("${path.module}/uasset/signed-url/user/response.vm")

  lambda_invoke_arn = var.uasset-user-signed-url-lambda-invoke-arn

  # Optional arguments
  http_method = "POST"
  validate_request_body = true
  validate_request_parameters = false
  content_handling = null
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.saints-xctf-com-fn-authorizer.id
}

resource "aws_lambda_permission" "allow-api-gateway-uasset-signed-url-user" {
  action = "lambda:InvokeFunction"
  function_name = var.uasset-user-signed-url-lambda-name
  statement_id = "AllowExecutionFromApiGateway"
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.saints-xctf-com-fn.execution_arn}/*/*/*"
}

/* POST /uasset/signed-url/group */

module "api-gateway-uasset-signed-url-group-endpoint" {
  source = "github.com/ajarombek/cloud-modules//terraform-modules/api-gateway-endpoint?ref=v0.2.8"

  # Mandatory arguments
  rest_api_id = aws_api_gateway_rest_api.saints-xctf-com-fn.id
  parent_path_id = aws_api_gateway_resource.saints-xctf-com-fn-uasset-signed-url-path.id
  path = "group"
  request_validator_name = "uasset-signed-url-group-request-body-${local.env}"

  request_templates = {
    "application/json" = file("${path.module}/uasset/signed-url/group/request.vm")
  }

  response_template = file("${path.module}/uasset/signed-url/group/response.vm")

  lambda_invoke_arn = var.uasset-group-signed-url-lambda-invoke-arn

  # Optional arguments
  http_method = "POST"
  validate_request_body = true
  validate_request_parameters = false
  content_handling = null
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.saints-xctf-com-fn-authorizer.id
}

resource "aws_lambda_permission" "allow-api-gateway-uasset-signed-url-group" {
  action = "lambda:InvokeFunction"
  function_name = var.uasset-group-signed-url-lambda-name
  statement_id = "AllowExecutionFromApiGateway"
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.saints-xctf-com-fn.execution_arn}/*/*/*"
}