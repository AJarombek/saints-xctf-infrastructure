/**
 * Infrastructure for an automated system of deploying database scripts to the SaintsXCTF development database.
 * Your mental well being is whats most important, I hope you are happy with yourself.  You deserve to be.
 * Author: Andrew Jarombek
 * Date: 9/17/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = ">= 2.66.0"
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/database-deployment/env/dev"
    region = "us-east-1"
  }
}

module "lambda" {
  source = "../../modules/lambda"
  prod = false
}