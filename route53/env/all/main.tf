/*
 * Confifure DNS and Domain Name Registration for SaintsXCTF
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
    key = "saints-xctf-infrastructure/route53/env/all"
    region = "us-east-1"
  }
}

#------------------------------
# New AWS Resources for Route53
#------------------------------

resource "aws_route53_zone" "saintsxctf" {
  name = "saintsxctf.com."
}

resource "aws_route53_record" "saintsxctf-ns" {
  name = "saintsxctf.com."
  type = "NS"
  zone_id = "${aws_route53_zone.saintsxctf.zone_id}"
  ttl = 172800

  records = [
    "${aws_route53_zone.saintsxctf.name_servers.0}",
    "${aws_route53_zone.saintsxctf.name_servers.1}",
    "${aws_route53_zone.saintsxctf.name_servers.2}",
    "${aws_route53_zone.saintsxctf.name_servers.3}"
  ]
}