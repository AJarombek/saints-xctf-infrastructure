/**
 * ACM certificates for the SaintsXCTF Application
 * Author: Andrew Jarombek
 * Date: 2/26/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = "~> 0.13.7"

  required_providers {
    aws = {
      source  = "-/aws"
      version = "~> 5.34.0"
    }
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "saints-xctf-infrastructure/acm/saints-xctf"
    region  = "us-east-1"
  }
}

locals {
  terraform_tag = "saints-xctf-infrastructure/acm/saints-xctf"
}

#--------------------------
# New AWS Resources for ACM
#--------------------------

module "saints-xctf-acm-certificate" {
  source = "github.com/ajarombek/cloud-modules//terraform-modules/acm-certificate?ref=v0.2.13"

  # Mandatory arguments
  name            = "saints-xctf-acm-certificate"
  route53_zone_name = "saintsxctf.com."
  acm_domain_name   = "saintsxctf.com"

  # Optional arguments
  route53_zone_private = false

  tags = {
    Name        = "saints-xctf-acm-certificate"
    Application = "saints-xctf"
    Environment = "production"
    Terraform   = local.terraform_tag
  }
}

module "saints-xctf-wildcard-acm-certificate" {
  source = "github.com/ajarombek/cloud-modules//terraform-modules/acm-certificate?ref=v0.2.13"

  # Mandatory arguments
  name            = "saints-xctf-wildcard-acm-certificate"
  route53_zone_name = "saintsxctf.com."
  acm_domain_name   = "*.saintsxctf.com"

  # Optional arguments
  route53_zone_private = false

  tags = {
    Name        = "saints-xctf-wildcard-acm-certificate"
    Application = "saints-xctf"
    Environment = "all"
    Terraform   = local.terraform_tag
  }
}