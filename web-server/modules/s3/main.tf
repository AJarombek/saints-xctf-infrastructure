/**
 * Infrastructure for the S3 bucket holding SaintsXCTF credentials
 * Author: Andrew Jarombek
 * Date: 2/16/2019
 */

locals {
  env = "${var.prod ? "prod" : "dev"}"
}

#---------------------------
# First Create the S3 Bucket
#---------------------------

resource "aws_s3_bucket" "saints-xctf-credentials" {
  bucket = "saints-xctf-credentials-${local.env}"

  cors_rule {
    allowed_origins = ["*"]
    allowed_methods = ["GET"]
    allowed_headers = ["*"]
  }

  tags {
    Name = "saints-xctf-credentials-${local.env}"
  }
}

#--------------------------------------
# Second Put Objects into the S3 Bucket
#--------------------------------------

resource "aws_s3_bucket_object" "bucket-objects" {
  count = "${length(var.contents)}"

  bucket = "${aws_s3_bucket.saints-xctf-credentials.id}"
  key = "${lookup(var.contents[count.index], "key", "")}"
  source = "contents/${lookup(var.contents[count.index], "source", "")}"
  etag = "${md5(file("contents/${lookup(var.contents[count.index], "source", "")}"))}"

  depends_on = ["aws_s3_bucket.saints-xctf-credentials"]
}

#-------------------------------
# Third Set the S3 Bucket Policy
#-------------------------------

resource "aws_s3_bucket_policy" "saints-xctf-credentials-policy" {
  bucket = "${aws_s3_bucket.saints-xctf-credentials.id}"
  policy = "${file("saints-xctf-credentials-policy.json")}"

  depends_on = ["aws_s3_bucket.saints-xctf-credentials", "aws_s3_bucket_object.bucket-objects"]
}