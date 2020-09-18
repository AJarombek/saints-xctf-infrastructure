/**
 * Infrastructure shared by development and production environments which deploy database scripts
 * to the SaintsXCTF database.
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
    key = "saints-xctf-infrastructure/database-deployment/env/all"
    region = "us-east-1"
  }
}

module "iam" {
  source = "../../modules/iam"
}

module "s3" {
  source = "../../modules/s3"
}