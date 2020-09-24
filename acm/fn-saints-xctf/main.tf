/**
 * ACM certificate for *.fn.saintsxctf.com
 * Author: Andrew Jarombek
 * Date: 7/18/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = "= 2.66.0"
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/acm/fn-saints-xctf"
    region = "us-east-1"
  }
}

#--------------------------
# New AWS Resources for ACM
#--------------------------

module "saints-xctf-fn-acm-certificate" {
  source = "github.com/ajarombek/terraform-modules//acm-certificate?ref=v0.1.8"

  # Mandatory arguments
  name = "saints-xctf-fn-acm-certificate"
  tag_name = "saints-xctf-fn-acm-certificate"
  tag_application = "saints-xctf"
  tag_environment = "production"

  route53_zone_name = "saintsxctf.com."
  acm_domain_name = "*.fn.saintsxctf.com"

  # Optional arguments
  route53_zone_private = false
}