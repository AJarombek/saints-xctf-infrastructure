/**
 * Infrastructure for the saintsxctf database backup S3 bucket in the PROD environment
 * Author: Andrew Jarombek
 * Date: 7/26/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.1.2"

  required_providers {
    aws = ">= 3.70.0"
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/database-backup/env/prod"
    region = "us-east-1"
  }
}

module "s3" {
  source = "../../modules/s3"
  prod = true
}