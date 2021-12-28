/**
 * Infrastructure for AWS Cloudwatch Synthetic Monitoring that is shared between development and production environments.
 * Author: Andrew Jarombek
 * Date: 7/4/2021
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.1.2"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.48.0"
    }
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/synthetic-monitoring/env/all"
    region = "us-east-1"
  }
}

module "s3" {
  source = "../../modules/s3"
}

module "iam" {
  source = "../../modules/iam"
}