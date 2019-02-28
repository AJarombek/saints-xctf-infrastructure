/*
 * Confifure DNS and Domain Name Registration for SaintsXCTF in the DEV environment
 * Author: Andrew Jarombek
 * Date: 2/28/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/route53/env/dev"
    region = "us-east-1"
  }
}

#------------------------------
# New AWS Resources for Route53
#------------------------------

module "route53" {
  source = "../../modules/route53"
  prod = false
}