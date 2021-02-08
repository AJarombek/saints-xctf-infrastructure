/**
 * AWS Lambda functions for sending emails
 * Author: Andrew Jarombek
 * Date: 5/24/2020
 */

locals {
  env = var.prod ? "prod" : "dev"
  url_prefix = var.prod ? "" : "dev."

  lambda_functions = {
    forgot_password = {
      function_name = "SaintsXCTFForgotPasswordEmail${upper(local.env)}"
      filename = "${path.module}/SaintsXCTFForgotPasswordEmail.zip"
      handler = "sendEmailAWS.sendForgotPasswordEmail"
      source_code_hash = filebase64sha256("${path.module}/SaintsXCTFForgotPasswordEmail.zip")
      description = "Send an email with a forgot password code when a user forgets their SaintsXCTF password."
      tags_name = "saints-xctf-com-lambda-forgot-password-email"
      log_group_name = "/aws/lambda/SaintsXCTFForgotPasswordEmail${upper(local.env)}"
    },
    activation_code = {
      function_name = "SaintsXCTFActivationCodeEmail${upper(local.env)}"
      filename = "${path.module}/SaintsXCTFActivationCodeEmail.zip"
      handler = "sendEmailAWS.sendActivationCodeEmail"
      source_code_hash = filebase64sha256("${path.module}/SaintsXCTFActivationCodeEmail.zip")
      description = "Send an email with an activation code for a new user to SaintsXCTF."
      tags_name = "saints-xctf-com-lambda-activation-code-email"
      log_group_name = "/aws/lambda/SaintsXCTFActivationCodeEmail${upper(local.env)}"
    },
    welcome = {
      function_name = "SaintsXCTFWelcomeEmail${upper(local.env)}"
      filename = "${path.module}/SaintsXCTFWelcomeEmail.zip"
      handler = "sendEmailAWS.sendWelcomeEmail"
      source_code_hash = filebase64sha256("${path.module}/SaintsXCTFWelcomeEmail.zip")
      description = "Send an email to welcome a new user to SaintsXCTF."
      tags_name = "saints-xctf-com-lambda-welcome-email"
      log_group_name = "/aws/lambda/SaintsXCTFWelcomeEmail${upper(local.env)}"
    }
  }
}

# I was hoping for enough snow today to XC ski through Central Park, but unfortunately its too warm and there wasn't
# enough precip.  They are saying this weekend there is a chance for snow too, so maybe I'll be able to go then.  Also
# I want to remind you how wonderful you are.

resource "aws_lambda_function" "email" {
  role = aws_iam_role.lambda-role.arn
  runtime = "nodejs12.x"
  timeout = 10
  memory_size = 128
  publish = true

  environment {
    variables = {
      PREFIX = local.url_prefix
    }
  }

  for_each = local.lambda_functions

  function_name = each.value.function_name
  filename = each.value.filename
  handler = each.value.handler
  source_code_hash = each.value.source_code_hash
  description = each.value.description

  tags = {
    Name = each.value.tags_name
    Environment = local.env
    Application = "saints-xctf-com"
  }
}

resource "aws_cloudwatch_log_group" "welcome-email-log-group" {
  retention_in_days = 7

  for_each = local.lambda_functions

  name = each.value.log_group_name
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