/**
 * Infrastructure for the saintsxctf RDS snapshot lambda function shared between all environments.
 * Author: Andrew Jarombek
 * Date: 7/19/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/database-snapshot/env/all"
    region = "us-east-1"
  }
}

module "iam" {
  source = "../../modules/iam"
}

module "vpc-endpoints" {
  source = "../../modules/vpc-endpoints"
}