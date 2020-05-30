/**
 * Authentication AWS Lambda function.
 * Author: Andrew Jarombek
 * Date: 5/25/2020
 */

locals {
  env = var.prod ? "prod" : "dev"
}

# ---------------------------------------
# Authorizer Lambda Function (Standalone)
# ---------------------------------------

resource "aws_lambda_function" "authorizer" {
  function_name = "SaintsXCTFAuthorizer${upper(local.env)}"
  filename = "${path.module}/SaintsXCTFAuthorizer.zip"
  handler = "function.lambda_handler"
  role = aws_iam_role.lambda-role.arn
  runtime = "python3.8"
  source_code_hash = filebase64sha256("${path.module}/SaintsXCTFAuthorizer.zip")
  timeout = 10

  tags = {
    Name = "saints-xctf-com-lambda-authorizer"
    Environment = local.env
    Application = "saints-xctf-com"
  }
}

resource "aws_cloudwatch_log_group" "authorizer-log-group" {
  name = "/aws/lambda/SaintsXCTFAuthorizer${upper(local.env)}"
  retention_in_days = 7
}

# -----------------------------------
# Rotate Lambda Function (Standalone)
# -----------------------------------

resource "aws_lambda_function" "rotate" {
  function_name = "SaintsXCTFRotate${upper(local.env)}"
  filename = "${path.module}/SaintsXCTFRotate.zip"
  handler = "function.lambda_handler"
  role = aws_iam_role.lambda-role.arn
  runtime = "python3.8"
  source_code_hash = filebase64sha256("${path.module}/SaintsXCTFRotate.zip")
  timeout = 10

  tags = {
    Name = "saints-xctf-com-lambda-rotate"
    Environment = local.env
    Application = "saints-xctf-com"
  }
}

resource "aws_cloudwatch_log_group" "rotate-log-group" {
  name = "/aws/lambda/SaintsXCTFRotate${upper(local.env)}"
  retention_in_days = 7
}

# ------------------------------------------
# Authenticate Lambda Function (API Gateway)
# ------------------------------------------

resource "aws_lambda_function" "authenticate" {
  function_name = "SaintsXCTFAuthenticate${upper(local.env)}"
  filename = "${path.module}/SaintsXCTFAuthenticate.zip"
  handler = "function.lambda_handler"
  role = aws_iam_role.lambda-role.arn
  runtime = "python3.8"
  source_code_hash = filebase64sha256("${path.module}/SaintsXCTFAuthenticate.zip")
  timeout = 10

  tags = {
    Name = "saints-xctf-com-lambda-authenticate"
    Environment = local.env
    Application = "saints-xctf-com"
  }
}

resource "aws_cloudwatch_log_group" "authenticate-log-group" {
  name = "/aws/lambda/SaintsXCTFAuthenticate${upper(local.env)}"
  retention_in_days = 7
}

# -----------------------------------
# Token Lambda Function (API Gateway)
# -----------------------------------

resource "aws_lambda_function" "token" {
  function_name = "SaintsXCTFToken${upper(local.env)}"
  filename = "${path.module}/SaintsXCTFToken.zip"
  handler = "function.lambda_handler"
  role = aws_iam_role.lambda-role.arn
  runtime = "python3.8"
  source_code_hash = filebase64sha256("${path.module}/SaintsXCTFToken.zip")
  timeout = 10

  tags = {
    Name = "saints-xctf-com-lambda-token"
    Environment = local.env
    Application = "saints-xctf-com"
  }
}

resource "aws_cloudwatch_log_group" "token-log-group" {
  name = "/aws/lambda/SaintsXCTFToken${upper(local.env)}"
  retention_in_days = 7
}

# ----------------
# Shared Resources
# ----------------

resource "aws_iam_role" "lambda-role" {
  name = "authorizer-lambda-role"
  path = "/saints-xctf-com/"
  assume_role_policy = file("${path.module}/lambda-role.json")
  description = "IAM role for logging and accessing secrets from an AWS Lambda function"
}

resource "aws_iam_policy" "lambda-policy" {
  name = "authorizer-lambda-policy"
  path = "/saints-xctf-com/"
  policy = file("${path.module}/lambda-policy.json")
  description = "IAM policy for logging and accessing secrets from an AWS Lambda function"
}

resource "aws_iam_role_policy_attachment" "lambda-policy-attachment" {
  role = aws_iam_role.lambda-role.name
  policy_arn = aws_iam_policy.lambda-policy.arn
}