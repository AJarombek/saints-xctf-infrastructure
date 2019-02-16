/**
 * Infrastructure for the global S3 bucket holding SaintsXCTF credentials
 * Author: Andrew Jarombek
 * Date: 12/10/2018
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/web-server/env/global"
    region = "us-east-1"
  }
}

module "s3-global" {
  source = "../../modules/s3-global"
}