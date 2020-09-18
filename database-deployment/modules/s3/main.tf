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