/**
 * Infrastructure for an S3 bucket used for backing up the MySQL saintsxctf database
 * Author: Andrew Jarombek
 * Date: 12/3/2018
 */

locals {
  env = "${var.prod ? "prod" : "dev"}"
}

#-------------
# S3 Resources
#-------------

/* The S3 bucket holding database backups keeps old files versioned for 60 days.  After that they are deleted. */
resource "aws_s3_bucket" "saints-xctf-db-backups" {
  bucket = "saints-xctf-db-backups-${local.env}"

  # Bucket owner gets full control, nobody else has access
  acl = "private"

  # Policy allows for resources in this AWS account to create and read objects
  # Must use the module relative path (path.module) - https://github.com/hashicorp/terraform/issues/5213
  policy = "${file("${path.module}/policies/policy-${local.env}.json")}"

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
    Application = "saints-xctf"
  }
}

#-------------------------------------
# Executed After Resources are Created
#-------------------------------------

resource "null_resource" "initial-backups" {
  provisioner "local-exec" {
    command = "bash ../../modules/s3/initial_backup.sh ${local.env}"
  }

  depends_on = ["aws_s3_bucket.saints-xctf-db-backups"]
}