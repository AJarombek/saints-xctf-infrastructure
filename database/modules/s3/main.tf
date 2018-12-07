/**
 * Infrastructure for an S3 bucket used for backing up the MySQL saintsxctf database
 * Author: Andrew Jarombek
 * Date: 12/3/2018
 */

resource "aws_s3_bucket" "saints-xctf-db-backups" {
  bucket = "saints-xctf-db-backups-${var.prod ? "prod" : "dev"}"

  # Bucket owner gets full control, nobody else has access
  acl = "private"

  # Policy allows for resources in this AWS account to create and read objects
  policy = "${file("policy.json")}"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_expiration {
      days = 60
    }
  }

  tags {
    Name = "SaintsXCTF Database Backups Bucket"
  }
}