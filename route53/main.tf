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
}

data "aws_instances" "saints-xctf-prod-instances" {
  filter {
    name = "Name"
    values = ["saints-xctf-server-prod-asg"]
  }

  instance_state_names = ["running"]
}

data "template_file" "saints-xctf-https-config-prod" {
  count = "${data.aws_instances.saints-xctf-prod-instances.count}"
  template = "${file("configure-https.sh")}"

  vars {
    ENV = "prod"
  }
}*/

data "aws_lb" "saints-xctf-dev-server-lb" {
  name = "saints-xctf-dev-server-lb"
}

data "aws_instances" "saints-xctf-dev-instances" {
  instance_tags {
    Name = "saints-xctf-server-dev-asg"
  }

  instance_state_names = ["running"]
}

data "template_file" "saints-xctf-https-config-dev" {
  count = "${data.aws_instances.saints-xctf-dev-instances.count}"
  template = "${file("configure-https.sh")}"

  vars {
    ENV = "dev"
  }
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
}

resource "aws_route53_record" "www-saintsxctf-com-a" {
  name = "www.saintsxctf.jarombek.io"
  type = "A"
  zone_id = "${data.aws_route53_zone.jarombek-io-zone.zone_id}"

  alias {
    evaluate_target_health = true
    name = "${data.aws_lb.saints-xctf-server-prod-application-lb.dns_name}"
    zone_id = "${data.aws_lb.saints-xctf-server-prod-application-lb.zone_id}"
  }
}

resource "null_resource" "prod-saintsxctf-com-https" {
  count = "${data.aws_instances.saints-xctf-prod-instances.count}"

  connection {
    type = "ssh"
    host = "${data.aws_instances.saints-xctf-prod-instances.public_ips[count.index]}"
    user = "ubuntu"
    port = 22
    private_key = "${file("~/Documents/saints-xctf-prod-key.pem")}"
    agent = true
    timeout = "3m"
  }

  provisioner "remote-exec" {
    inline = ["${data.template_file.saints-xctf-https-config-prod.rendered}"]
  }

  depends_on = ["aws_route53_record.saintsxctf-com-a", "aws_route53_record.www-saintsxctf-com-a"]
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

resource "aws_route53_record" "www-dev-saintsxctf-com-a" {
  name = "www.saintsxctfdev.jarombek.io"
  type = "A"
  zone_id = "${data.aws_route53_zone.jarombek-io-zone.zone_id}"

  alias {
    evaluate_target_health = true
    name = "${data.aws_lb.saints-xctf-dev-server-lb.dns_name}"
    zone_id = "${data.aws_lb.saints-xctf-dev-server-lb.zone_id}"
  }
}

resource "null_resource" "dev-saintsxctf-com-https" {
  count = "${data.aws_instances.saints-xctf-dev-instances.count}"

  connection {
    type = "ssh"
    host = "${data.aws_instances.saints-xctf-dev-instances.public_ips[count.index]}"
    user = "ubuntu"
    port = 22
    private_key = "${file("~/Documents/saints-xctf-dev-key.pem")}"
    agent = true
    timeout = "3m"
  }

  provisioner "remote-exec" {
    inline = ["${data.template_file.saints-xctf-https-config-dev.rendered}"]
  }

  depends_on = ["aws_route53_record.dev-saintsxctf-com-a", "aws_route53_record.www-dev-saintsxctf-com-a"]
}