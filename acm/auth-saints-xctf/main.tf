/**
 * ACM certificate for *.auth.saintsxctf.com
 * Author: Andrew Jarombek
 * Date: 7/18/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/acm/auth-saints-xctf"
    region = "us-east-1"
  }
}

#--------------------------
# New AWS Resources for ACM
#--------------------------

module "saints-xctf-auth-acm-certificate" {
  source = "github.com/ajarombek/terraform-modules//acm-certificate?ref=v0.1.8"

  # Mandatory arguments
  name = "saints-xctf-auth-acm-certificate"
  tag_name = "saints-xctf-auth-acm-certificate"
  tag_application = "saints-xctf"
  tag_environment = "production"

  route53_zone_name = "saintsxctf.com."
  acm_domain_name = "*.auth.saintsxctf.com"

  # Optional arguments
  route53_zone_private = false
}