/**
 * ACM certificates for the SaintsXCTF Application
 * Author: Andrew Jarombek
 * Date: 2/26/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

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

/* A Route53 zone is needed for the certificate validation records */
data "aws_route53_zone" "saints-xctf-zone" {
  name = "saintsxctf.com."
  private_zone = false
}

#--------------------------
# New AWS Resources for ACM
#--------------------------

#--------------------------
# Protects 'saintsxctf.com'
#--------------------------

resource "aws_acm_certificate" "saints-xctf-acm-certificate" {
  domain_name = "saintsxctf.com"
  validation_method = "DNS"

  tags = {
    Environment = "production"
    Application = "saints-xctf"
  }

  lifecycle {
    create_before_destroy = true
  }
}

/* Create a validation record used for certificate validation through DNS */
resource "aws_route53_record" "saints-xctf-cert-validation-record" {
  name = aws_acm_certificate.saints-xctf-acm-certificate.domain_validation_options[0].resource_record_name
  type = aws_acm_certificate.saints-xctf-acm-certificate.domain_validation_options[0].resource_record_type
  zone_id = data.aws_route53_zone.saints-xctf-zone.id
  records = [aws_acm_certificate.saints-xctf-acm-certificate.domain_validation_options[0].resource_record_value]
  ttl = 60
}

/* Request a DNS validation certificate */
resource "aws_acm_certificate_validation" "saints-xctf-cert-validation" {
  certificate_arn = aws_acm_certificate.saints-xctf-acm-certificate.arn
  validation_record_fqdns = [aws_route53_record.saints-xctf-cert-validation-record.fqdn]
}

#----------------------------
# Protects '*.saintsxctf.com'
#----------------------------

resource "aws_acm_certificate" "saints-xctf-wildcard-acm-certificate" {
  domain_name = "*.saintsxctf.com"
  validation_method = "DNS"

  tags = {
    Environment = "all"
    Application = "saints-xctf"
  }

  lifecycle {
    create_before_destroy = true
  }
}

/* Create a validation record used for certificate validation through DNS */
resource "aws_route53_record" "saints-xctf-wc-cert-validation-record" {
  name = aws_acm_certificate.saints-xctf-wildcard-acm-certificate.domain_validation_options[0].resource_record_name
  type = aws_acm_certificate.saints-xctf-wildcard-acm-certificate.domain_validation_options[0].resource_record_type
  zone_id = data.aws_route53_zone.saints-xctf-zone.id
  records = [aws_acm_certificate.saints-xctf-wildcard-acm-certificate.domain_validation_options[0].resource_record_value]
  ttl = 60
}

/* Request a DNS validation certificate */
resource "aws_acm_certificate_validation" "saints-xctf-wc-cert-validation" {
  certificate_arn = aws_acm_certificate.saints-xctf-wildcard-acm-certificate.arn
  validation_record_fqdns = [aws_route53_record.saints-xctf-wc-cert-validation-record.fqdn]
}

#--------------------------------
# Protects '*.asset.saintsxctf.com'
#--------------------------------

resource "aws_acm_certificate" "saints-xctf-asset-wildcard-acm-certificate" {
  domain_name = "*.asset.saintsxctf.com"
  validation_method = "DNS"

  tags = {
    Environment = "production"
    Application = "saints-xctf"
  }

  lifecycle {
    # Replace a certificate that is currently in use
    create_before_destroy = true
  }
}

/* Create a validation record used for certificate validation through DNS */
resource "aws_route53_record" "saints-xctf-asset-wc-cert-validation-record" {
  name = aws_acm_certificate.saints-xctf-asset-wildcard-acm-certificate.domain_validation_options[0].resource_record_name
  type = aws_acm_certificate.saints-xctf-asset-wildcard-acm-certificate.domain_validation_options[0].resource_record_type
  zone_id = data.aws_route53_zone.saints-xctf-zone.id
  records = [aws_acm_certificate.saints-xctf-asset-wildcard-acm-certificate.domain_validation_options[0].resource_record_value]
  ttl = 60
}

/* Request a DNS validation certificate */
resource "aws_acm_certificate_validation" "saints-xctf-asset-wc-cert-validation" {
  certificate_arn = aws_acm_certificate.saints-xctf-asset-wildcard-acm-certificate.arn
  validation_record_fqdns = [aws_route53_record.saints-xctf-asset-wc-cert-validation-record.fqdn]
}

#--------------------------------
# Protects '*.uasset.saintsxctf.com'
#--------------------------------

resource "aws_acm_certificate" "saints-xctf-uasset-wildcard-acm-certificate" {
  domain_name = "*.uasset.saintsxctf.com"
  validation_method = "DNS"

  tags = {
    Environment = "production"
    Application = "saints-xctf"
  }

  lifecycle {
    # Replace a certificate that is currently in use
    create_before_destroy = true
  }
}

/* Create a validation record used for certificate validation through DNS */
resource "aws_route53_record" "saints-xctf-uasset-wc-cert-validation-record" {
  name = aws_acm_certificate.saints-xctf-uasset-wildcard-acm-certificate.domain_validation_options[0].resource_record_name
  type = aws_acm_certificate.saints-xctf-uasset-wildcard-acm-certificate.domain_validation_options[0].resource_record_type
  zone_id = data.aws_route53_zone.saints-xctf-zone.id
  records = [aws_acm_certificate.saints-xctf-uasset-wildcard-acm-certificate.domain_validation_options[0].resource_record_value]
  ttl = 60
}

/* Request a DNS validation certificate */
resource "aws_acm_certificate_validation" "saints-xctf-uasset-wc-cert-validation" {
  certificate_arn = aws_acm_certificate.saints-xctf-uasset-wildcard-acm-certificate.arn
  validation_record_fqdns = [aws_route53_record.saints-xctf-uasset-wc-cert-validation-record.fqdn]
}

#--------------------------------
# Protects '*.dev.saintsxctf.com'
#--------------------------------

resource "aws_acm_certificate" "saints-xctf-dev-wildcard-acm-certificate" {
  domain_name = "*.dev.saintsxctf.com"
  validation_method = "DNS"

  tags = {
    Environment = "development"
    Application = "saints-xctf"
  }

  lifecycle {
    # Replace a certificate that is currently in use
    create_before_destroy = true
  }
}

/* Create a validation record used for certificate validation through DNS */
resource "aws_route53_record" "saints-xctf-dev-wc-cert-validation-record" {
  name = aws_acm_certificate.saints-xctf-dev-wildcard-acm-certificate.domain_validation_options[0].resource_record_name
  type = aws_acm_certificate.saints-xctf-dev-wildcard-acm-certificate.domain_validation_options[0].resource_record_type
  zone_id = data.aws_route53_zone.saints-xctf-zone.id
  records = [aws_acm_certificate.saints-xctf-dev-wildcard-acm-certificate.domain_validation_options[0].resource_record_value]
  ttl = 60
}

/* Request a DNS validation certificate */
resource "aws_acm_certificate_validation" "saints-xctf-dev-wc-cert-validation" {
  certificate_arn = aws_acm_certificate.saints-xctf-dev-wildcard-acm-certificate.arn
  validation_record_fqdns = [aws_route53_record.saints-xctf-dev-wc-cert-validation-record.fqdn]
}