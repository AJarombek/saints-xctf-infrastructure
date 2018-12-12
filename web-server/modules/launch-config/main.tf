/**
 * Infrastructure for the saintsxctf website launch configuration of EC2 instances
 * Author: Andrew Jarombek
 * Date: 12/10/2018
 */

locals {
  env = "${var.prod ? "prod" : "dev"}"
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_vpc" "saints-xctf-vpc" {
  tags {
    Name = "SaintsXCTFcom VPC"
  }
}

data "aws_subnet" "saints-xctf-vpc-public-subnet" {
  tags {
    Name = "SaintsXCTFcom VPC Public Subnet"
  }
}

data "aws_security_group" "public-subnet-security-group" {
  filter {
    name = "group-name"
    values = ["saintsxctfcom-vpc-public-security"]
  }
}

data "aws_ami" "saints-xctf-ami" {
  most_recent = true

  filter {
    name = "name"
    values = ["saints-xctf-web-server*"]
  }

  owners = ["739088120071"]
}

data "template_file" "saints-xctf-startup" {
  template = "${file("saints-xctf-startup.sh")}"
}

#----------------------------------------------------------
# New AWS Resources for the SaintsXCTF Launch Configuration
#----------------------------------------------------------

resource "aws_launch_configuration" "saints-xctf-server-lc" {
  name = "saints-xctf-server-${local.env}-lc"
  image_id = "${data.aws_ami.saints-xctf-ami.id}"
  instance_type = "t2.micro"
  security_groups = ["${}"]

  user_data = "${data.template_file.saints-xctf-startup.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "saints-xctf-asg" {
  launch_configuration = "${aws_launch_configuration.saints-xctf-server-lc.id}"
  vpc_zone_identifier = ["${data.aws_subnet.saints-xctf-vpc-public-subnet.id}"]

  max_size = "${var.max_size}"
  min_size = "${var.min_size}"
  desired_capacity = "${var.desired_capacity}"

  load_balancers = ["${aws_elb}"]
  health_check_type = "ELB"
  health_check_grace_period = 600

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key = "Name"
    propagate_at_launch = false
    value = "saints-xctf-server-${local.env}-asg"
  }
}

resource "aws_autoscaling_schedule" "saints-xctf-server-asg-schedule" {
  count = "${length(var.autoscaling_schedules)}"

  autoscaling_group_name = "${aws_autoscaling_group.saints-xctf-asg.name}"
  scheduled_action_name = "${lookup(element(var.autoscaling_schedules, count.index), "name", "default-schedule")}"

  max_size = "${lookup(element(var.autoscaling_schedules, count.index), "max_size", 0)}"
  min_size = "${lookup(element(var.autoscaling_schedules, count.index), "min_size", 0)}"
  desired_capacity = "${lookup(element(var.autoscaling_schedules, count.index), "desired_capacity", 0)}"

  recurrence = "${lookup(element(var.autoscaling_schedules, count.index), "recurrence", "0 5 * * *")}"
}

resource "aws_elb" "saints-xctf-server-elb" {
  name = "saints-xctf-${local.env}-server-elb"

  subnets = ["${data.aws_subnet.saints-xctf-vpc-public-subnet.id}"]
  security_groups = [
    "${data.aws_security_group.public-subnet-security-group.id}",
    "${}"
  ]

  listener {
    instance_port = "${var.instance_port}"
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "TCP:${var.instance_port}"
  }

  tags {
    Name = "SaintsXCTFcom Server ${upper(local.env)} ELB"
  }
}

resource "aws_security_group" "saints-xctf-server-lc-security-group" {
  
}