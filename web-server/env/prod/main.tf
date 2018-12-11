/**
 * Infrastructure for the saintsxctf launch configuration in the PROD environment
 * Author: Andrew Jarombek
 * Date: 12/10/2018
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/web-server/env/prod"
    region = "us-east-1"
  }
}

module "launch-config" {
  source = "../../modules/launch-config"
  prod = true
}