/**
 * Infrastructure for the canary function S3 bucket module.
 * Author: Andrew Jarombek
 * Date: 7/4/2021
 */

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "saints-xctf-canaries" {
  bucket = "saints-xctf-canaries"
  acl = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_expiration {
      days = 60
    }
  }

  # 6/20 - I hope you are doing okay, ran a fun little race in Rowayton CT today.
  # 7/4 - Ran 15.5 miles today, surprisingly felt really good.  Hope you are enjoying your long weekend.

  tags = {
    Name = "saints-xctf-canaries"
    Application = "saints-xctf"
    Environment = "all"
  }
}

resource "aws_s3_bucket_public_access_block" "saints-xctf-canaries" {
  bucket = aws_s3_bucket.saints-xctf-canaries.id

  block_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true
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