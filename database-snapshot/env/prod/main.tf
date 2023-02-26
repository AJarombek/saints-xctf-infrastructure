/**
 * Infrastructure for the saintsxctf RDS snapshot lambda function in the PROD environment
 * Author: Andrew Jarombek
 * Date: 6/7/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "saints-xctf-infrastructure/database-snapshot/env/prod"
    region  = "us-east-1"
  }
}

module "lambda" {
  source = "../../modules/lambda"
  prod   = true
}