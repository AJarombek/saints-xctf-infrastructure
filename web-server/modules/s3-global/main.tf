/**
 * Infrastructure for the global S3 bucket holding SaintsXCTF credentials
 * Author: Andrew Jarombek
 * Date: 2/16/2019
 */

resource "aws_s3_bucket" "saints-xctf-credentials" {
  bucket = "saints-xctf-credentials"

  tags {
    Name = "saints-xctf-credentials"
  }
}