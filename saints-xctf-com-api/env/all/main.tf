/**
 * Infrastructure for api.saintsxctf.com on Kubernetes in all environments
 * Author: Andrew Jarombek
 * Date: 7/13/2020
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
    key = "jarombek-com-infrastructure/saints-xctf-com-api/env/all"
    region = "us-east-1"
  }
}

module "ecr" {
  source = "../../modules/ecr"
}