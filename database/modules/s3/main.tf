/**
 * Infrastructure for an S3 bucket used for backing up the MySQL saintsxctf database
 * Author: Andrew Jarombek
 * Date: 12/3/2018
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/database/s3"
    region = "us-east-1"
  }
}

#----------------------------------------
# SaintsXCTF S3 Database Backup Resources
#----------------------------------------

resource "aws_s3_bucket" "saints-xctf-db-backups" {
  bucket = "saints-xctf-db-backups"

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