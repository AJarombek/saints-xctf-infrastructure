/**
 * Infrastructure for the saintsxctf database in the PROD environment
 * Author: Andrew Jarombek
 * Date: 12/6/2018
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = "~> 1.6.6"

  required_providers {
    aws = "~> 5.32.1"
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "saints-xctf-infrastructure/database/env/prod"
    region  = "us-east-1"
  }
}

module "rds" {
  source        = "../../modules/rds"
  prod          = true
  username      = var.username
  password      = var.password
  terraform_tag = "saints-xctf-infrastructure/database/env/prod"
}