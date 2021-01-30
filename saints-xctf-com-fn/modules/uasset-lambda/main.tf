/**
 * AWS Lambda functions for manipulating objects in the uasset.saintsxctf.com S3 bucket.
 * Author: Andrew Jarombek
 * Date: 11/21/2020
 */

locals {
  env = var.prod ? "prod" : "dev"

  lambda_functions = {
    uasset_user = {
      function_name = "SaintsXCTFUassetUser${upper(local.env)}"
      filename = "${path.module}/SaintsXCTFUassetUser.zip"
      source_code_hash = filebase64sha256("${path.module}/SaintsXCTFUassetUser.zip")
      description = "Upload a user's profile picture to the uasset.saintsxctf.com S3 bucket."
      tags_name = "saints-xctf-com-lambda-uasset-user"
      log_group_name = "/aws/lambda/SaintsXCTFUassetUser${upper(local.env)}"
    },
    uasset_group = {
      function_name = "SaintsXCTFUassetGroup${upper(local.env)}"
      filename = "${path.module}/SaintsXCTFUassetGroup.zip"
      source_code_hash = filebase64sha256("${path.module}/SaintsXCTFUassetGroup.zip")
      description = "Upload a group's picture to the uasset.saintsxctf.com S3 bucket."
      tags_name = "saints-xctf-com-lambda-uasset-group"
      log_group_name = "/aws/lambda/SaintsXCTFUassetGroup${upper(local.env)}"
    }
  }
}

data "aws_lambda_layer_version" "upload-picture-layer" {
  layer_name = "upload-picture-layer"
}

resource "aws_lambda_function" "uasset" {
  handler = "index.handler"
  role = aws_iam_role.lambda-role.arn
  runtime = "nodejs12.x"
  timeout = 10
  memory_size = 128

  layers = [data.aws_lambda_layer_version.upload-picture-layer.arn]

  environment {
    variables = {
      ENV = local.env
    }
  }

  for_each = local.lambda_functions

  function_name = each.value.function_name
  filename = each.value.filename
  source_code_hash = each.value.source_code_hash
  description = each.value.description

  tags = {
    Name = each.value.tags_name
    Environment = local.env
    Application = "saints-xctf-com"
  }
}

resource "aws_cloudwatch_log_group" "uasset-user-log-group" {
  retention_in_days = 7

  for_each = local.lambda_functions

  name = each.value.log_group_name
}

data "aws_iam_policy_document" "lambda-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com", "apigateway.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "lambda-role" {
  name = "uasset-lambda-role"
  path = "/saints-xctf-com/"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role-policy.json
  description = "IAM role for an AWS Lambda function that interacts with the uasset.saintsxctf.com S3 bucket"
}

data "aws_iam_policy_document" "lambda-policy" {
  statement {
    sid = "UassetLambda"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }

  statement {
    sid = "UassetLambdaS3"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = ["arn:aws:s3:::uasset.saintsxctf.com/*"]
  }
}

resource "aws_iam_policy" "lambda-policy" {
  name = "uasset-lambda-policy"
  path = "/saints-xctf-com/"
  policy = data.aws_iam_policy_document.lambda-policy.json
  description = "IAM policy for an AWS Lambda function that interacts with the uasset.saintsxctf.com S3 bucket"
}

resource "aws_iam_role_policy_attachment" "lambda-logging-policy-attachment" {
  role = aws_iam_role.lambda-role.name
  policy_arn = aws_iam_policy.lambda-policy.arn
}