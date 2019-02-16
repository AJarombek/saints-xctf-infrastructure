/**
 * Infrastructure for the global S3 bucket holding SaintsXCTF credentials
 * Author: Andrew Jarombek
 * Date: 2/16/2019
 */

resource "aws_s3_bucket" "saints-xctf-credentials" {
  bucket = "saints-xctf-credentials"
  policy = "${file("saints-xctf-credentials-policy.json")}"

  cors_rule {
    allowed_origins = ["*"]
    allowed_methods = ["GET"]
    allowed_headers = ["*"]
  }

  tags {
    Name = "saints-xctf-credentials"
  }
}