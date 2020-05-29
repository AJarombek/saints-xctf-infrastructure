/**
 * Authentication AWS Lambda function.
 * Author: Andrew Jarombek
 * Date: 5/25/2020
 */

locals {
  env = var.prod ? "prod" : "dev"
}

resource "aws_lambda_function" "auth" {
  function_name = "SaintsXCTFAuthorizer${upper(local.env)}"
  filename = "${path.module}/SaintsXCTFAuthorizer.zip"
  handler = "function.auth"
  role = aws_iam_role.lambda-role.arn
  runtime = "nodejs12.x"
  source_code_hash = filebase64sha256("${path.module}/SaintsXCTFAuthorizer.zip")
  timeout = 10

  tags = {
    Name = "saints-xctf-com-lambda-auth"
    Environment = local.env
    Application = "saints-xctf-com"
  }
}

resource "aws_cloudwatch_log_group" "auth-log-group" {
  name = "/aws/lambda/SaintsXCTFAuth${upper(local.env)}"
  retention_in_days = 7
}

resource "aws_iam_role" "lambda-role" {
  name = "auth-lambda-role"
  path = "/saints-xctf-com/"
  assume_role_policy = file("${path.module}/lambda-role.json")
  description = "IAM role for logging from an AWS Lambda function"
}

resource "aws_iam_policy" "lambda-policy" {
  name = "auth-lambda-policy"
  path = "/saints-xctf-com/"
  policy = file("${path.module}/lambda-policy.json")
  description = "IAM policy for logging from an AWS Lambda function"
}

resource "aws_iam_role_policy_attachment" "lambda-policy-attachment" {
  role = aws_iam_role.lambda-role.name
  policy_arn = aws_iam_policy.lambda-policy.arn
}