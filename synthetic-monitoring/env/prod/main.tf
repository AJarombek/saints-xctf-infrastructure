/**
 * Infrastructure for the AWS Cloudwatch Synthetic Monitoring.  In essence, these "canary" functions provide end to end
 * tests of critical paths of the SaintsXCTF application in the PROD environment.
 * Author: Andrew Jarombek
 * Date: 6/14/2021
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.1.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.48.0"
    }
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "saints-xctf-infrastructure/synthetic-monitoring/env/prod"
    region  = "us-east-1"
  }
}

module "canaries" {
  source = "../../modules/canaries"
  prod   = true
}