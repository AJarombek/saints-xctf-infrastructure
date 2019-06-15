/**
 * Infrastructure for the SaintsXCTF Secrets Manager in the PROD environment
 * Author: Andrew Jarombek
 * Date: 6/14/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/secrets-manager/env/prod"
    region = "us-east-1"
  }
}

module "lambda" {
  source = "../../modules/secrets"
  prod = true
}