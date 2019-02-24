/**
 * Infrastructure for the saintsxctf launch configuration in the PROD environment
 * Author: Andrew Jarombek
 * Date: 12/10/2018
 */

locals {
  # Environment
  prod = true
  env = "${local.prod ? "prod" : "dev"}"

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
    key = "saints-xctf-infrastructure/web-server/env/prod"
    region = "us-east-1"
  }
}

data "aws_security_group" "saints-xctf-database-sg" {
  tags {
    Name = "saints-xctf-database-security-${local.prod ? "prod" : "dev"}"
  }
}

module "launch-config" {
  source = "../../modules/launch-config"
  prod = "${local.prod}"
  instance_port = "${local.instance_port}"

  autoscaling_schedules = []

  launch-config-sg-rules-cidr = [
    {
      # Inbound traffic from the internet
      type = "ingress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      # Outbound traffic for calling the API
      type = "egress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      # Outbound traffic for SendMail
      type = "egress"
      from_port = 25
      to_port = 25
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
    },
    {
      # Outbound traffic for calling the API
      type = "egress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      # Outbound traffic for SendMail
      type = "egress"
      from_port = 25
      to_port = 25
      protocol = "tcp"
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