/**
 * IAM infrastructure for GitHub Actions Terraform deployments.
 * Author: Andrew Jarombek
 * Date: 6/23/2026
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = "~> 6.2.0"
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "saints-xctf-infrastructure/iam-github-terraform"
    region  = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}

# Created manually in the AWS console.
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "github_terraform" {
  name = "saints-xctf-github-terraform"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:AJarombek/saints-xctf-infrastructure:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "terraform_backend" {
  name        = "saints-xctf-terraform-backend-access"
  description = "Permissions for Terraform S3 state and DynamoDB lock table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::andrew-jarombek-terraform-state",
          "arn:aws:s3:::andrew-jarombek-terraform-state/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem"
        ]
        Resource = "arn:aws:dynamodb:us-east-1:${data.aws_caller_identity.current.account_id}:table/terraform-locks"
      }
    ]
  })
}

resource "aws_iam_policy" "terraform_services" {
  name        = "saints-xctf-github-terraform-services-admin"
  description = "Service-scoped admin permissions for GitHub Actions Terraform"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:Get*",
          "iam:List*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:UpdateRole",
          "iam:DeleteRole",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:PassRole",
          "iam:CreatePolicy",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:DeletePolicy",
          "iam:TagPolicy",
          "iam:UntagPolicy",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:CreateServiceLinkedRole"
        ]
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/saints*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/saints*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "acm:*",
          "application-autoscaling:*",
          "cloudwatch:*",
          "dynamodb:*",
          "ec2:*",
          "ecr:*",
          "ecs:*",
          "eks:*",
          "elasticloadbalancing:*",
          "events:*",
          "kms:*",
          "logs:*",
          "rds:*",
          "route53:*",
          "s3:*",
          "secretsmanager:*",
          "ssm:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_terraform_backend" {
  role       = aws_iam_role.github_terraform.name
  policy_arn = aws_iam_policy.terraform_backend.arn
}

resource "aws_iam_role_policy_attachment" "github_terraform_services" {
  role       = aws_iam_role.github_terraform.name
  policy_arn = aws_iam_policy.terraform_services.arn
}

