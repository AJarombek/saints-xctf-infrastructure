/**
 * Infrastructure for the S3 bucket objects holding SaintsXCTF credentials
 * Author: Andrew Jarombek
 * Date: 2/16/2019
 */

locals {
  env = "${var.prod ? "prod" : "dev"}"
}