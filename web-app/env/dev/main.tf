/**
 * Infrastructure for the SaintsXCTF Applications S3 bucket in the DEV environment
 * Author: Andrew Jarombek
 * Date: 2/16/2019
 */

locals {
  prod = false
  env = "${local.prod ? "prod" : "dev"}"
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/web-app/env/dev"
    region = "us-east-1"
  }
}

module "s3" {
  source = "../../modules/s3"
  prod = "${local.prod}"

  contents = [
    {
      key = "${local.env}/date.js",
      source = "date.js"
    },
    {
      key = "${local.env}/models/clientcred.php",
      source = "clientcred.php"
    },
    {
      key = "${local.env}/api/cred.php",
      source = "cred.php"
    },
    {
      key = "${local.env}/api/apicred.php",
      source = "apicred.php"
    }
  ]
}