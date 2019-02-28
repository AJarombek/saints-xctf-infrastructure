/**
 * DNS records for the SaintsXCTF Application
 * Author: Andrew Jarombek
 * Date: 2/16/2019
 */

locals {
  env = "${var.prod ? "prod" : "dev"}"
  env_record = "${var.prod ? "saintsxctf.jarombek.io" : "saintsxctfdev.jarombek.io"}"
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_route53_zone" "jarombek-io-zone" {
  name = "jarombek.io."
}

data "aws_lb" "saints-xctf-server-lb" {
  name = "saints-xctf-${local.env}-server-lb"

  # This is kinda a hack - https://github.com/hashicorp/terraform/issues/16380#issuecomment-356247591
  depends_on = ["data.aws_route53_zone.jarombek-io-zone"]
}

data "aws_autoscaling_group" "saints-xctf-asg" {
  name = "saints-xctf-server-${local.env}-asg"

  depends_on = ["data.aws_lb.saints-xctf-server-lb"]
}

data "aws_instances" "saints-xctf-instances" {
  instance_tags {
    Name = "saints-xctf-server-${local.env}-asg"
  }

  instance_state_names = ["running"]

  depends_on = ["data.aws_autoscaling_group.saints-xctf-asg"]
}

data "template_file" "saints-xctf-https-config" {
  count = "${data.aws_instances.saints-xctf-instances.count}"
  template = "${file("${path.module}/configure-https.sh")}"

  vars {
    ENV = "${local.env}"
  }
}

#------------------------------
# New AWS Resources for Route53
#------------------------------

resource "aws_route53_record" "saintsxctf-com-a" {
  name = "${local.env_record}"
  type = "A"
  zone_id = "${data.aws_route53_zone.jarombek-io-zone.zone_id}"

  alias {
    evaluate_target_health = true
    name = "${data.aws_lb.saints-xctf-server-lb.dns_name}"
    zone_id = "${data.aws_lb.saints-xctf-server-lb.zone_id}"
  }
}

resource "aws_route53_record" "www-saintsxctf-com-a" {
  name = "www.${local.env_record}"
  type = "A"
  zone_id = "${data.aws_route53_zone.jarombek-io-zone.zone_id}"

  alias {
    evaluate_target_health = true
    name = "${data.aws_lb.saints-xctf-server-lb.dns_name}"
    zone_id = "${data.aws_lb.saints-xctf-server-lb.zone_id}"
  }
}

resource "null_resource" "dev-saintsxctf-com-https" {
  count = "${data.aws_instances.saints-xctf-instances.count}"

  connection {
    type = "ssh"
    host = "${data.aws_instances.saints-xctf-instances.public_ips[count.index]}"
    user = "ubuntu"
    port = 22
    private_key = "${file("~/Documents/saints-xctf-dev-key.pem")}"
    agent = true
    timeout = "3m"
  }

  provisioner "remote-exec" {
    inline = ["${data.template_file.saints-xctf-https-config.rendered}"]
  }

  depends_on = ["aws_route53_record.saintsxctf-com-a", "aws_route53_record.www-saintsxctf-com-a"]
}