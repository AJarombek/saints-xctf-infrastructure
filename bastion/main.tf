/**
 * Infrastructure for creating a bastion host to private subnet resources
 * Author: Andrew Jarombek
 * Date: 2/12/2019
 */

locals {
  public_cidr = "0.0.0.0/0"
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/bastion"
    region = "us-east-1"
  }
}

data "aws_subnet" "saints-xctf-public-subnet-1" {
  tags {
    Name = "SaintsXCTFcom VPC Public Subnet 1"
  }
}

data "aws_vpc" "saints-xctf-vpc" {
  tags {
    Name = "SaintsXCTFcom VPC"
  }
}

resource "aws_instance" "bastion" {
  # Use Amazon Linux 2
  ami = "ami-035be7bafff33b6b6"

  instance_type = "t2.micro"
  key_name = "bastion-key"
  associate_public_ip_address = true

  subnet_id = "${data.aws_subnet.saints-xctf-public-subnet-1.id}"
  security_groups = ["${module.bastion-subnet-security-group.security_group_id}"]

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "Bastion Host"
  }
}

module "bastion-subnet-security-group" {
  source = "github.com/ajarombek/terraform-modules//security-group"

  # Mandatory arguments
  name = "bastion-security"
  tag_name = "Bastion Security Group"
  vpc_id = "${data.aws_vpc.saints-xctf-vpc.id}"

  # Optional arguments
  sg_rules = [
    # Inbound traffic for SSH
    {
      type = "ingress"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      # Inbound traffic for ping
      type = "ingress"
      from_port = -1
      to_port = -1
      protocol = "icmp"
      cidr_blocks = "${local.public_cidr}"
    }
  ]

  description = "Allow SSH connections"
}