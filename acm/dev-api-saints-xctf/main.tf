/**
 * ACM certificate for *.dev.api.saintsxctf.com
 * Author: Andrew Jarombek
 * Date: 2/19/2023
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = "= 2.66.0"
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/acm/dev-api-saints-xctf"
    region = "us-east-1"
  }
}

#--------------------------
# New AWS Resources for ACM
#--------------------------

module "saints-xctf-dev-api-acm-certificate" {
  source = "github.com/ajarombek/terraform-modules//acm-certificate?ref=v0.1.13"

  # Mandatory arguments
  name = "saints-xctf-dev-api-acm-certificate"
  tag_name = "saints-xctf-dev-api-acm-certificate"
  tag_application = "saints-xctf"
  tag_environment = "development"

  route53_zone_name = "saintsxctf.com."
  acm_domain_name = "*.dev.api.saintsxctf.com"

  # Optional arguments
  route53_zone_private = false
}