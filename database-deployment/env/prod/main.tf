/**
 * Infrastructure for an automated system of deploying database scripts to the SaintsXCTF production database.
 * Author: Andrew Jarombek
 * Date: 9/17/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = ">= 3.7.0"
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/database-deployment/env/prod"
    region = "us-east-1"
  }
}

module "lambda" {
  source = "../../modules/lambda"
  prod = true
}