/**
 * Infrastructure for the saintsxctf database in the PROD environment
 * Author: Andrew Jarombek
 * Date: 12/6/2018
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/database/env/prod"
    region = "us-east-1"
  }
}

module "rds" {
  source = "../../modules/rds"
  prod = true
}

module "s3" {
  source = "../../modules/s3"
  prod = true
}