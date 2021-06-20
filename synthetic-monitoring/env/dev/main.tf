/**
 * Infrastructure for AWS Cloudwatch Synthetic Monitoring.  In essence, these "canary" functions provide end to end
 * tests of critical paths of the SaintsXCTF application in the DEV environment.
 * Author: Andrew Jarombek
 * Date: 6/14/2021
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.15.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.42.0"
    }
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/synthetic-monitoring/env/dev"
    region = "us-east-1"
  }
}

module "canaries" {
  source = "../../modules/canaries"
  prod = false
}