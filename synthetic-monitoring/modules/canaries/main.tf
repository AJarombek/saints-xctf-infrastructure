/**
 * Infrastructure for the canary function module.
 * Author: Andrew Jarombek
 * Date: 6/14/2021
 */

locals {
  env = var.prod ? "prod" : "dev"
  environment = var.prod ? "production" : "development"
}

resource "aws_synthetics_canary" "saints-xctf-sign-in" {
  name = "saints-xctf-sign-in-${local.env}"
  runtime_version = "syn-nodejs-puppeteer-3.1"
  handler = "exports.handler"
  zip_file = "SaintsXCTFSignIn.zip"

  schedule {
    expression = "rate(1 hour)"
  }

  tags = {
    Name = "saints-xctf-sign-in-${local.env}"
    Environment = local.environment
    Application = "saints-xctf"
  }
}