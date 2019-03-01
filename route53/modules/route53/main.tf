/**
 * DNS records for the SaintsXCTF Application
 * Author: Andrew Jarombek
 * Date: 2/16/2019
 */

locals {
  env = "${var.prod ? "prod" : "dev"}"
  env_key = "${var.prod ? "saints-xctf-key.pem" : "saints-xctf-dev-key.pem"}"
  env_record = "${var.prod ? "saintsxctf.com" : "dev.saintsxctf.com"}"
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_route53_zone" "saintsxctf-com-zone" {
  name = "saintsxctf.com."
}

data "aws_lb" "saints-xctf-dev-server-lb" {
  name = "saints-xctf-${local.env}-server-lb"
}

data "aws_autoscaling_group" "saints-xctf-asg" {
  name = "saints-xctf-server-${local.env}-asg"
}

data "aws_instances" "saints-xctf-instances" {
  instance_tags {
    Name = "saints-xctf-server-${local.env}-asg"
  }

  instance_state_names = ["running"]
}

data "template_file" "saints-xctf-https-config" {
  count = "${data.aws_instances.saints-xctf-instances.count}"
  template = "${file("${path.module}/configure-https.sh")}"

  vars {
    URL = "${var.prod ? "saintsxctf.com" : "dev.saintsxctf.com"}"
  }
}

#------------------------------
# New AWS Resources for Route53
#------------------------------

resource "aws_route53_record" "saintsxctf-com-a" {
  name = "${local.env_record}"
  type = "A"
  zone_id = "${data.aws_route53_zone.saintsxctf-com-zone.zone_id}"

  alias {
    evaluate_target_health = true
    name = "${data.aws_lb.saints-xctf-dev-server-lb.dns_name}"
    zone_id = "${data.aws_lb.saints-xctf-dev-server-lb.zone_id}"
  }
}

resource "aws_route53_record" "www-saintsxctf-com-a" {
  name = "www.${local.env_record}"
  type = "A"
  zone_id = "${data.aws_route53_zone.saintsxctf-com-zone.zone_id}"

  alias {
    evaluate_target_health = true
    name = "${data.aws_lb.saints-xctf-dev-server-lb.dns_name}"
    zone_id = "${data.aws_lb.saints-xctf-dev-server-lb.zone_id}"
  }
}

resource "null_resource" "saintsxctf-com-https" {
  count = "${data.aws_instances.saints-xctf-instances.count}"

  connection {
    type = "ssh"
    host = "${data.aws_instances.saints-xctf-instances.public_ips[count.index]}"
    user = "ubuntu"
    port = 22
    private_key = "${file("~/Documents/${local.env_key}")}"
    agent = true
    timeout = "3m"
  }

  provisioner "remote-exec" {
    inline = ["${data.template_file.saints-xctf-https-config.rendered}"]
  }

  depends_on = ["aws_route53_record.saintsxctf-com-a", "aws_route53_record.www-saintsxctf-com-a"]
}