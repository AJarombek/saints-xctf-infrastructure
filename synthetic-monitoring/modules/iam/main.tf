/**
 * Infrastructure for the canary function IAM policies and roles module.
 * Author: Andrew Jarombek
 * Date: 7/4/2021
 */

data "aws_iam_policy_document" "canary-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "canary-role" {
  name = "canary-role"
  path = "/saints-xctf-com/"
  assume_role_policy = data.aws_iam_policy_document.canary-assume-role-policy.json
  description = "IAM role for AWS Synthetic Monitoring Canaries"
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
  name = "canary-policy"
  path = "/saints-xctf-com/"
  policy = data.aws_iam_policy_document.canary-policy.json
  description = "IAM role for AWS Synthetic Monitoring Canaries"
}

resource "aws_iam_role_policy_attachment" "canary-policy-attachment" {
  role = aws_iam_role.canary-role.name
  policy_arn = aws_iam_policy.canary-policy.arn
}