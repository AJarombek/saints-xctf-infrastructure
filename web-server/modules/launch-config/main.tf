/**
 * Infrastructure for the saintsxctf website launch configuration of EC2 instances
 * Author: Andrew Jarombek
 * Date: 12/10/2018
 */

locals {
  env = "${var.prod ? "prod" : "dev"}"
  subnet_number = "${var.prod ? 0 : 1}"
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
    Name = "SaintsXCTFcom VPC Public Subnet ${local.subnet_number}"
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
  security_groups = ["${aws_security_group.saints-xctf-server-lc-security-group.id}"]

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

resource "aws_lb" "saints-xctf-server-application-lb" {
  name = "saints-xctf-${local.env}-server-application-lb"
  load_balancer_type = "application"

  subnets = ["${data.aws_subnet.saints-xctf-vpc-public-subnet.id}"]
  security_groups = ["${aws_security_group.saints-xctf-server-elb-security-group.id}"]

  tags {
    Name = "SaintsXCTFcom Server ${upper(local.env)} Application LB"
  }
}

resource "aws_lb_listener" "saints-xctf-server-application-lb-listener" {
  load_balancer_arn = "${aws_lb.saints-xctf-server-application-lb.arn}"
  port = 80
  protocol = "http"

  default_action {
    target_group_arn = "${aws_lb_target_group.saints-xctf-server-application-lb-target-group.arn}"
    type = "forward"
  }
}

resource "aws_lb_target_group" "saints-xctf-server-application-lb-target-group" {
  name = "saints-xctf-server-lb-target"

  health_check {
    interval = 10
    timeout = 5
    healthy_threshold = 3
    unhealthy_threshold = 2
    protocol = "http"
    path = "/"
    matcher = "200-299"
  }

  port = 80
  protocol = "http"
  vpc_id = "${data.aws_vpc.saints-xctf-vpc.id}"

  tags {
    Name = "SaintsXCTFcom Server ${upper(local.env)} Application LB Target Group"
  }
}

resource "aws_security_group" "saints-xctf-server-lc-security-group" {
  name = "saints-xctf-${local.env}-server-lc-security-group"
  vpc_id = "${data.aws_vpc.saints-xctf-vpc.id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "saints-xctf-server-lc-security-group-rule" {
  count = "${length(var.launch-config-sg-rules)}"

  security_group_id = "${aws_security_group.saints-xctf-server-lc-security-group.id}"
  type = "${lookup(element(var.launch-config-sg-rules, count.index), "type", "ingress")}"

  from_port = "${lookup(element(var.launch-config-sg-rules, count.index), "from_port", 0)}"
  to_port = "${lookup(element(var.launch-config-sg-rules, count.index), "to_port", 0)}"
  protocol = "${lookup(element(var.launch-config-sg-rules, count.index), "protocol", "-1")}"

  cidr_blocks = ["${lookup(element(var.launch-config-sg-rules, count.index), "cidr_blocks", null)}"]
  source_security_group_id = "${lookup(element(var.launch-config-sg-rules, count.index), "source_sg", null)}"
}

resource "aws_security_group" "saints-xctf-server-elb-security-group" {
  name = "saints-xctf-${local.env}-server-elb-security-group"
  vpc_id = "${data.aws_vpc.saints-xctf-vpc.id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "saints-xctf-server-elb-security-group-rule" {
  count = "${length(var.load-balancer-sg-rules)}"

  security_group_id = "${aws_security_group.saints-xctf-server-elb-security-group.id}"
  type = "${lookup(element(var.load-balancer-sg-rules, count.index), "type", "ingress")}"

  from_port = "${lookup(element(var.load-balancer-sg-rules, count.index), "from_port", 0)}"
  to_port = "${lookup(element(var.load-balancer-sg-rules, count.index), "to_port", 0)}"
  protocol = "${lookup(element(var.load-balancer-sg-rules, count.index), "protocol", "-1")}"

  cidr_blocks = ["${lookup(element(var.load-balancer-sg-rules, count.index), "cidr_blocks", null)}"]
  source_security_group_id = "${lookup(element(var.load-balancer-sg-rules, count.index), "source_sg", null)}"
}