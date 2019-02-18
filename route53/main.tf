/**
 * DNS records for the SaintsXCTF Application
 * Author: Andrew Jarombek
 * Date: 2/16/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/route53"
    region = "us-east-1"
  }
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_route53_zone" "jarombek-io-zone" {
  name = "jarombek.io."
}
/*
data "aws_lb" "saints-xctf-prod-server-lb" {
  name = "saints-xctf-prod-server-lb"
}*/

data "aws_lb" "saints-xctf-dev-server-lb" {
  name = "saints-xctf-dev-server-lb"
}

#------------------------------
# New AWS Resources for Route53
#------------------------------
/*
resource "aws_route53_record" "saintsxctf-com-a" {
  name = "saintsxctf.jarombek.io"
  type = "A"
  zone_id = "${data.aws_route53_zone.jarombek-io-zone.zone_id}"

  alias {
    evaluate_target_health = true
    name = "${data.aws_lb.saints-xctf-server-prod-application-lb.dns_name}"
    zone_id = "${data.aws_lb.saints-xctf-server-prod-application-lb.zone_id}"
  }
}*/

resource "aws_route53_record" "dev-saintsxctf-com-a" {
  name = "saintsxctfdev.jarombek.io"
  type = "A"
  zone_id = "${data.aws_route53_zone.jarombek-io-zone.zone_id}"

  alias {
    evaluate_target_health = true
    name = "${data.aws_lb.saints-xctf-dev-server-lb.dns_name}"
    zone_id = "${data.aws_lb.saints-xctf-dev-server-lb.zone_id}"
  }
}