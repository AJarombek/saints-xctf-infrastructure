/**
 * Infrastructure shared between all environments for the SaintsXCTF authentication API.
 * Author: Andrew Jarombek
 * Date: 7/26/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.33.0"
    }
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/saints-xctf-com-auth/env/all"
    region = "us-east-1"
  }
}

module "vpc-endpoints" {
  source = "../../modules/vpc-endpoints"
}