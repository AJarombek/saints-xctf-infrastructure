/**
 * AWS Lambda functions for sending emails
 * Author: Andrew Jarombek
 * Date: 5/24/2020
 */

locals {
  env = var.prod ? "prod" : "dev"
  url_prefix = var.prod ? "" : "dev."
}

resource "aws_lambda_function" "forgot-password-email" {
  function_name = "SaintsXCTFForgotPasswordEmail${upper(local.env)}"
  filename = "${path.module}/SaintsXCTFForgotPasswordEmail.zip"
  handler = "sendEmailAWS.sendForgotPasswordEmail"
  role = aws_iam_role.lambda-role.arn
  runtime = "nodejs12.x"
  source_code_hash = filebase64sha256("${path.module}/SaintsXCTFForgotPasswordEmail.zip")
  timeout = 10

  environment {
    variables = {
      PREFIX = local.url_prefix
    }
  }

  tags = {
    Name = "saints-xctf-com-lambda-forgot-password-email"
    Environment = local.env
    Application = "saints-xctf-com"
  }
}

resource "aws_cloudwatch_log_group" "welcome-email-log-group" {
  name = "/aws/lambda/SaintsXCTFForgotPasswordEmail${upper(local.env)}"
  retention_in_days = 7
}

resource "aws_iam_role" "lambda-role" {
  name = "email-lambda-role"
  path = "/saints-xctf-com/"
  assume_role_policy = file("${path.module}/lambda-role.json")
  description = "IAM role for logging & secrets for an AWS Lambda function"
}

resource "aws_iam_policy" "lambda-policy" {
  name = "email-lambda-policy"
  path = "/saints-xctf-com/"
  policy = file("${path.module}/lambda-policy.json")
  description = "IAM policy for logging & secrets for an AWS Lambda function"
}

resource "aws_iam_role_policy_attachment" "lambda-logging-policy-attachment" {
  role = aws_iam_role.lambda-role.name
  policy_arn = aws_iam_policy.lambda-policy.arn
}