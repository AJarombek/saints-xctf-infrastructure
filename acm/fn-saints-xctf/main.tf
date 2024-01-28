/**
 * ACM certificate for *.fn.saintsxctf.com
 * Author: Andrew Jarombek
 * Date: 7/18/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = "~> 1.6.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.34.0"
    }
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "saints-xctf-infrastructure/acm/fn-saints-xctf"
    region  = "us-east-1"
  }
}

locals {
  terraform_tag = "saints-xctf-infrastructure/acm/fn-saints-xctf"
}

#--------------------------
# New AWS Resources for ACM
#--------------------------

module "saints-xctf-fn-acm-certificate" {
  source = "github.com/ajarombek/cloud-modules//terraform-modules/acm-certificate?ref=v0.2.13"

  # Mandatory arguments
  name              = "saints-xctf-fn-acm-certificate"
  route53_zone_name = "saintsxctf.com."
  acm_domain_name   = "*.fn.saintsxctf.com"

  # Optional arguments
  route53_zone_private = false

  tags = {
    Name        = "saints-xctf-fn-acm-certificate"
    Application = "saints-xctf"
    Environment = "production"
    Terraform   = local.terraform_tag
  }
}