/**
 * Infrastructure for the canary function module.
 * Author: Andrew Jarombek
 * Date: 6/14/2021
 */

locals {
  env = var.prod ? "prod" : "dev"
  environment = var.prod ? "production" : "development"
}

data "aws_s3_bucket" "saints-xctf-canaries" {
  bucket = "saints-xctf-canaries"
}

data "aws_iam_role" "canary-role" {
  name = "canary-role"
}

data "aws_sns_topic" "alert-email" {
  name = "alert-email-topic"
}

# I hope you are doing well :).  I think you are so wonderful and sweet.
# Ran 16 miles today with Joe and felt pretty good!

resource "aws_synthetics_canary" "saints-xctf-forgot-password" {
  name = "sxctf-forgot-pw-${local.env}"
  artifact_s3_location = "s3://${data.aws_s3_bucket.saints-xctf-canaries.id}/"
  execution_role_arn = data.aws_iam_role.canary-role.arn
  runtime_version = "syn-python-selenium-1.0"
  handler = "forgot_password.handler"
  zip_file = "${path.module}/SaintsXCTFForgotPassword.zip"
  start_canary = false

  success_retention_period = 2
  failure_retention_period = 14

  schedule {
    expression = "rate(1 hour)"
    duration_in_seconds = 300
  }

  run_config {
    timeout_in_seconds = 300
    memory_in_mb = 960
    active_tracing = false
  }

  tags = {
    Name = "sxctf-forgot-password-${local.env}"
    Environment = local.environment
    Application = "saints-xctf"
  }
}

resource "aws_cloudwatch_event_rule" "saints-xctf-forgot-password-canary-event-rule" {
  name = "saints-xctf-forgot-password-canary-rule"
  event_pattern = jsonencode({
    source = ["aws.synthetics"]
    detail = {
      "canary-name": [aws_synthetics_canary.saints-xctf-forgot-password.name],
      "test-run-status": ["FAILED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "saints-xctf-forgot-password-canary-event-target" {
  target_id = "SaintsXCTFForgotPasswordCanaryTarget"
  arn = data.aws_sns_topic.alert-email.arn
  rule = aws_cloudwatch_event_rule.saints-xctf-forgot-password-canary-event-rule.name
}

resource "aws_synthetics_canary" "saints-xctf-up" {
  name = "sxctf-up-${local.env}"
  artifact_s3_location = "s3://${data.aws_s3_bucket.saints-xctf-canaries.id}/"
  execution_role_arn = data.aws_iam_role.canary-role.arn
  runtime_version = "syn-nodejs-puppeteer-3.1"
  handler = "up.handler"
  zip_file = "${path.module}/SaintsXCTFUp.zip"
  start_canary = false

  success_retention_period = 2
  failure_retention_period = 14

  schedule {
    expression = "rate(1 hour)"
    duration_in_seconds = 300
  }

  run_config {
    timeout_in_seconds = 300
    memory_in_mb = 960
    active_tracing = false
  }

  tags = {
    Name = "sxctf-up-${local.env}"
    Environment = local.environment
    Application = "saints-xctf"
  }
}

resource "aws_cloudwatch_event_rule" "saints-xctf-up-canary-event-rule" {
  name = "saints-xctf-up-canary-rule"
  event_pattern = jsonencode({
    source = ["aws.synthetics"]
    detail = {
      "canary-name": [aws_synthetics_canary.saints-xctf-up.name],
      "test-run-status": ["FAILED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "saints-xctf-up-canary-event-target" {
  target_id = "SaintsXCTFUpCanaryTarget"
  arn = data.aws_sns_topic.alert-email.arn
  rule = aws_cloudwatch_event_rule.saints-xctf-up-canary-event-rule.name
}

resource "aws_synthetics_canary" "saints-xctf-sign-in" {
  name = "sxctf-sign-in-${local.env}"
  artifact_s3_location = "s3://${data.aws_s3_bucket.saints-xctf-canaries.id}/"
  execution_role_arn = data.aws_iam_role.canary-role.arn
  runtime_version = "syn-nodejs-puppeteer-3.1"
  handler = "signIn.handler"
  zip_file = "${path.module}/SaintsXCTFSignIn.zip"
  start_canary = true

  success_retention_period = 2
  failure_retention_period = 14

  schedule {
    expression = "rate(1 hour)"
    duration_in_seconds = 0
  }

  run_config {
    timeout_in_seconds = 300
    memory_in_mb = 960
    active_tracing = false
  }

  tags = {
    Name = "sxctf-sign-in-${local.env}"
    Environment = local.environment
    Application = "saints-xctf"
  }
}

resource "aws_cloudwatch_event_rule" "saints-xctf-sign-in-canary-event-rule" {
  name = "saints-xctf-sign-in-canary-rule"
  event_pattern = jsonencode({
    source = ["aws.synthetics"]
    detail = {
      "canary-name": [aws_synthetics_canary.saints-xctf-sign-in.name],
      "test-run-status": ["FAILED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "saints-xctf-sign-in-canary-event-target" {
  target_id = "SaintsXCTFSignInCanaryTarget"
  arn = data.aws_sns_topic.alert-email.arn
  rule = aws_cloudwatch_event_rule.saints-xctf-sign-in-canary-event-rule.name
}