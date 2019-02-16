/**
 * Infrastructure for the saintsxctf launch configuration in the DEV environment
 * Author: Andrew Jarombek
 * Date: 12/10/2018
 */

locals {
  # Environment
  prod = false

  # Autoscaling schedules
  max_size_on = 1
  min_size_on = 1
  desired_capacity_on = 1

  max_size_off = 0
  min_size_off = 0
  desired_capacity_off = 0

  # Port for load balancer to listen to on EC2 instances
  instance_port = 8080

  # CIDR blocks for firewalls
  public_cidr = "0.0.0.0/0"
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/web-server/env/dev"
    region = "us-east-1"
  }
}

data "aws_security_group" "saints-xctf-database-sg" {
  tags {
    Name = "SaintsXCTFcom MySQL ${upper(local.prod ? "PROD" : "DEV")} Database Security"
  }
}

module "launch-config" {
  source = "../../modules/launch-config"
  prod = "${local.prod}"
  instance_port = "${local.instance_port}"

  autoscaling_schedules = [
    {
      name = "saints-xctf-server-online-weekday-morning"
      max_size = "${local.max_size_on}"
      min_size = "${local.min_size_on}"
      desired_capacity = "${local.desired_capacity_on}"
      recurrence = "30 11 * * 1-5"
    },
    {
      name = "saints-xctf-server-offline-weekday-morning"
      max_size = "${local.max_size_off}"
      min_size = "${local.min_size_off}"
      desired_capacity = "${local.desired_capacity_off}"
      recurrence = "30 13 * * 1-5"
    },
    {
      name = "saints-xctf-server-online-weekday-afternoon"
      max_size = "${local.max_size_on}"
      min_size = "${local.min_size_on}"
      desired_capacity = "${local.desired_capacity_on}"
      recurrence = "30 22 * * 1-5"
    },
    {
      name = "saints-xctf-server-offline-weekday-night"
      max_size = "${local.max_size_off}"
      min_size = "${local.min_size_off}"
      desired_capacity = "${local.desired_capacity_off}"
      recurrence = "30 3 * * 2-6"
    },
    {
      name = "saints-xctf-server-online-weekend"
      max_size = "${local.max_size_on}"
      min_size = "${local.min_size_on}"
      desired_capacity = "${local.desired_capacity_on}"
      recurrence = "30 11 * * 0,6"
    },
    {
      name = "saints-xctf-server-offline-weekend"
      max_size = "${local.max_size_off}"
      min_size = "${local.min_size_off}"
      desired_capacity = "${local.desired_capacity_off}"
      recurrence = "30 3 * * 0,1"
    }
  ]

  launch-config-sg-rules-cidr = [
    {
      # Inbound traffic from the internet
      type = "ingress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    }
  ]

  launch-config-sg-rules-source = [
    {
      # Outbound traffic to the MySQL database
      type = "egress"
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      source_sg = "${data.aws_security_group.saints-xctf-database-sg.id}"
    }
  ]

  load-balancer-sg-rules-cidr = [
    {
      # Inbound traffic from the internet
      type = "ingress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      # Outbound traffic for health checks
      type = "egress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = "${local.public_cidr}"
    }
  ]

  load-balancer-sg-rules-source = [
    {
      # Outbound traffic to the MySQL database
      type = "egress"
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      source_sg = "${data.aws_security_group.saints-xctf-database-sg.id}"
    }
  ]
}