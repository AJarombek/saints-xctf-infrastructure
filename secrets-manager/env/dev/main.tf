/**
 * Infrastructure for the SaintsXCTF Secrets Manager in the DEV environment
 * Author: Andrew Jarombek
 * Date: 6/14/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "saints-xctf-infrastructure/secrets-manager/env/dev"
    region  = "us-east-1"
  }
}

module "lambda" {
  source      = "../../modules/secrets"
  prod        = false
  rds_secrets = var.rds_secrets
}