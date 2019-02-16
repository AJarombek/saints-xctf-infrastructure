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

#-----------------------
# Existing AWS Resources
#-----------------------

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

data "aws_iam_role" "rds-access-role" {
  name = "rds-access-role"
}

data "template_file" "jenkins-startup" {
  template = "${file("bastion-setup.sh")}"
}

#--------------------------------------
# Executed Before Resources are Created
#--------------------------------------

resource "null_resource" "bastion-key-gen" {
  provisioner "local-exec" {
    command = "bash bastion-key-gen.sh"
  }
}

#------------------------------
# New AWS Resources for Bastion
#------------------------------

resource "aws_instance" "bastion" {
  # Use Amazon Linux 2
  ami = "ami-035be7bafff33b6b6"

  instance_type = "t2.micro"
  key_name = "bastion-key"
  associate_public_ip_address = true

  subnet_id = "${data.aws_subnet.saints-xctf-public-subnet-1.id}"
  security_groups = ["${module.bastion-subnet-security-group.security_group_id}"]
  iam_instance_profile = "${aws_iam_instance_profile.bastion-instance-profile.name}"

  lifecycle {
    create_before_destroy = true
  }

  user_data = "${data.template_file.jenkins-startup.rendered}"

  tags {
    Name = "bastion-host"
  }

  depends_on = ["null_resource.bastion-key-gen"]
}

resource "aws_iam_instance_profile" "bastion-instance-profile" {
  name = "bastion-instance-profile"
  role = "${data.aws_iam_role.rds-access-role.name}"
}

module "bastion-subnet-security-group" {
  source = "github.com/ajarombek/terraform-modules//security-group"

  # Mandatory arguments
  name = "bastion-security"
  tag_name = "Bastion Security Group"
  vpc_id = "${data.aws_vpc.saints-xctf-vpc.id}"

  # Optional arguments
  sg_rules = [
    {
      # Inbound traffic for SSH
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
    },
    {
      # Outbound traffic for HTTP
      type = "egress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      # Outbound traffic for HTTP
      type = "egress"
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      # Outbound traffic for MySQL
      type = "egress"
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    }
  ]

  description = "Allow SSH connections"
}