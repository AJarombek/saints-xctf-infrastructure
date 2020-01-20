/**
 * Assets for the website located on an S3 bucket.  These assets belong to the website, not the users of the website.
 * This S3 bucket has the domain asset.saintsxctf.com
 * Author: Andrew Jarombek
 * Date: 1/20/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/s3-asset"
    region = "us-east-1"
  }
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_acm_certificate" "wildcard-saints-xctf-com-cert" {
  domain = "*.saintsxctf.com"
}

data "aws_route53_zone" "saintsxctf" {
  name = "saintsxctf.com."
}

#--------------------------------------
# New AWS Resources for S3 & CloudFront
#--------------------------------------

resource "aws_s3_bucket" "asset-saintsxctf" {
  bucket = "asset.saintsxctf.com"
  acl = "public-read"
  policy = file("${path.module}/policy.json")

  tags = {
    Name = "asset.saintsxctf.com"
  }

  website {
    index_document = "saintsxctf.png"
    error_document = "saintsxctf.png"
  }

  cors_rule {
    allowed_origins = ["*"]
    allowed_methods = ["GET"]
    allowed_headers = ["*"]
  }
}