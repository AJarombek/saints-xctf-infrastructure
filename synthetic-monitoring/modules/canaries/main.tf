/**
 * Infrastructure for the canary function module.
 * Author: Andrew Jarombek
 * Date: 6/14/2021
 */

locals {
  env = var.prod ? "prod" : "dev"
  environment = var.prod ? "production" : "development"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "saints-xctf-canaries" {
  bucket = "saints-xctf-canaries-${local.env}"
  acl = "private"
  policy = file("${path.module}/policy.json")

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_expiration {
      days = 60
    }
  }

  tags = {
    Name = "saints-xctf-canaries-${local.env}"
    Application = "saints-xctf"
    Environment = local.environment
  }
}

resource "aws_s3_bucket_policy" "saints-xctf-canaries-policy" {
  bucket = aws_s3_bucket.saints-xctf-canaries.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id = "SaintsXCTFCanariesPolicy"
    Statement = [
      {
        Sid = "Permissions"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_caller_identity.current.account_id
        }
        Action = ["s3:*"]
        Resource = ["${aws_s3_bucket.saints-xctf-canaries.arn}/*"]
      }
    ]
  })
}

data "aws_iam_policy_document" "canary-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"

    principals {
      identifiers = ["synthetics.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "canary-role" {
  name = "canary-role-${local.env}"
  path = "/saints-xctf-com/"
  assume_role_policy = data.aws_iam_policy_document.canary-assume-role-policy.json
  description = "IAM role for AWS Synthetic Monitoring Canaries in the ${upper(local.env)} environment"
}

data "aws_iam_policy_document" "canary-policy" {
  statement {
    sid = "UassetLambda"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
      "cloudwatch:PutMetricData",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "canary-policy" {
  name = "canary-policy-${local.env}"
  path = "/saints-xctf-com/"
  policy = data.aws_iam_policy_document.canary-policy.json
  description = "IAM role for AWS Synthetic Monitoring Canaries in the ${upper(local.env)} environment"
}

resource "aws_iam_role_policy_attachment" "canary-policy-attachment" {
  role = aws_iam_role.canary-role.name
  policy_arn = aws_iam_policy.canary-policy.arn
}

resource "aws_synthetics_canary" "saints-xctf-sign-in" {
  name = "saints-xctf-sign-in-${local.env}"
  artifact_s3_location = "s3://${aws_s3_bucket.saints-xctf-canaries.id}/"
  execution_role_arn = aws_iam_role.canary-role.arn
  runtime_version = "syn-nodejs-puppeteer-3.1"
  handler = "exports.handler"
  zip_file = "SaintsXCTFSignIn.zip"

  schedule {
    expression = "rate(1 hour)"
  }

  tags = {
    Name = "saints-xctf-sign-in-${local.env}"
    Environment = local.environment
    Application = "saints-xctf"
  }
}