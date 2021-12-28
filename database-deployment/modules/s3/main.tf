/**
 * Infrastructure for an S3 bucket used for SaintsXCTF database deployments.
 * Author: Andrew Jarombek
 * Date: 9/17/2020
 */

resource "aws_s3_bucket" "saints-xctf-database-deployments" {
  bucket = "saints-xctf-database-deployments"
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
    Name = "saints-xctf-database-deployments"
    Application = "saints-xctf"
    Environment = "All"
  }
}

resource "aws_s3_bucket_public_access_block" "saints-xctf-database-deployments" {
  bucket = aws_s3_bucket.saints-xctf-database-deployments.id

  block_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true
}