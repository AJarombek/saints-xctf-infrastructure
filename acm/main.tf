/**
 * ACM certificates for the SaintsXCTF Application
 * Author: Andrew Jarombek
 * Date: 2/26/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/acm"
    region = "us-east-1"
  }
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_route53_zone" "saints-xctf-zone" {
  name = "jarombek.io."
  private_zone = false
}

#--------------------------
# New AWS Resources for ACM
#--------------------------

resource "aws_acm_certificate" "saints-xctf-dev-acm-certificate" {
  domain_name = "*.jarombek.io"
  validation_method = "DNS"

  tags {
    Environment = "dev"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "saints-xctf-dev-cert-validation-record" {
  name = "${aws_acm_certificate.saints-xctf-dev-acm-certificate.domain_validation_options.0.resource_record_name}"
  type = "${aws_acm_certificate.saints-xctf-dev-acm-certificate.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.saints-xctf-zone.id}"
  records = ["${aws_acm_certificate.saints-xctf-dev-acm-certificate.domain_validation_options.0.resource_record_value}"]
  ttl = 60
}

resource "aws_acm_certificate_validation" "saints-xctf-dev-cert-validation" {
  certificate_arn = "${aws_acm_certificate.saints-xctf-dev-acm-certificate.arn}"
  validation_record_fqdns = ["${aws_route53_record.saints-xctf-dev-cert-validation-record.fqdn}"]
}
/*
resource "aws_acm_certificate" "saints-xctf-acm-certificate" {
  domain_name = "saintsxctf.com"
  validation_method = "DNS"

  tags {
    Environment = "prod"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "saints-xctf-cert-validation-record" {
  name = "${aws_acm_certificate.saints-xctf-acm-certificate.domain_validation_options.0.resource_record_name}"
  type = "${aws_acm_certificate.saints-xctf-acm-certificate.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.saints-xctf-zone.id}"
  records = ["${aws_acm_certificate.saints-xctf-acm-certificate.domain_validation_options.0.resource_record_value}"]
  ttl = 60
}

resource "aws_acm_certificate_validation" "saints-xctf-cert-validation" {
  certificate_arn = "${aws_acm_certificate.saints-xctf-acm-certificate.arn}"
  validation_record_fqdns = ["${aws_route53_record.saints-xctf-cert-validation-record.fqdn}"]
}*/