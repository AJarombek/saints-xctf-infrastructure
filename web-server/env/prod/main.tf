/**
 * Infrastructure for the saintsxctf launch configuration in the PROD environment
 * Author: Andrew Jarombek
 * Date: 12/10/2018
 */

locals {
  prod = true
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
    Name = "SaintsXCTFcom MySQL ${upper(local.prod ? "PROD" : "DEV")} Database Security"
  }
}

module "launch-config" {
  source = "../../modules/launch-config"
  prod = "${local.prod}"

  launch-config-sg-rules = [
    {
      # Inbound traffic from the internet
      type = "ingress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      # Outbound traffic to the MySQL database
      type = "egress"
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      source_sg = "${data.aws_security_group.saints-xctf-database-sg.id}"
    }
  ]

  load-balancer-sg-rules = [
    {
      # Inbound traffic from the internet
      type = "ingress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      # Outbound traffic for health checks
      type = "egress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    },
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