/**
 * Infrastructure for the SaintsXCTF Applications S3 bucket in the PROD environment
 * Author: Andrew Jarombek
 * Date: 2/16/2019
 */

locals {
  prod = true
  env = local.prod ? "prod" : "dev"
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/web-app/env/prod"
    region = "us-east-1"
  }
}

module "s3" {
  source = "../../modules/s3"
  prod = local.prod

  contents = [
    {
      key = "date.js",
      source = "date.js"
    },
    {
      key = "models/clientcred.php",
      source = "clientcred.php"
    },
    {
      key = "api/cred.php",
      source = "cred.php"
    },
    {
      key = "api/apicred.php",
      source = "apicred.php"
    }
  ]
}