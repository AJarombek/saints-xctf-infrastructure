/**
 * ACM certificate for *.api.saintsxctf.com and *.dev.api.saintsxctf.com
 * Author: Andrew Jarombek
 * Date: 9/23/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = "= 2.66.0"
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/acm/api-saints-xctf"
    region = "us-east-1"
  }
}

#--------------------------
# New AWS Resources for ACM
#--------------------------

module "saints-xctf-api-acm-certificate" {
  source = "github.com/ajarombek/terraform-modules//acm-certificate?ref=v0.1.13"

  # Mandatory arguments
  name = "saints-xctf-api-acm-certificate"
  tag_name = "saints-xctf-api-acm-certificate"
  tag_application = "saints-xctf"
  tag_environment = "production"

  route53_zone_name = "saintsxctf.com."
  acm_domain_name = "*.api.saintsxctf.com"

  # Optional arguments
  route53_zone_private = false
}