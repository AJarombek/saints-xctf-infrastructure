/**
 * Infrastructure for creating a bastion host to private subnet resources
 * Author: Andrew Jarombek
 * Date: 2/12/2019
 */

locals {
  public_cidr = "0.0.0.0/0"
  my_cidr = "69.124.72.192/32"
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

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
  tags = {
    Name = "saints-xctf-com-lisag-public-subnet"
  }
}

data "aws_vpc" "saints-xctf-vpc" {
  tags = {
    Name = "saints-xctf-com-vpc"
  }
}

data "aws_iam_role" "rds-access-role" {
  name = "rds-access-role"
}

data "template_file" "bastion-startup" {
  template = file("bastion-setup.sh")
}

#--------------------------------------
# Executed Before Resources are Created
#--------------------------------------

/* Generate a SSH key used to connect to the Bastion host from my local machine */
resource "null_resource" "bastion-key-gen" {
  provisioner "local-exec" {
    command = "bash bastion-key-gen.sh"
  }
}

#------------------------------
# New AWS Resources for Bastion
#------------------------------

/* EC2 instance for the bastion host.  It runs Amazon Linux 2 and can be accessed with bastion-key */
resource "aws_instance" "bastion" {
  # Use Amazon Linux 2
  ami = "ami-035be7bafff33b6b6"

  instance_type = "t2.micro"
  key_name = "bastion-key"
  associate_public_ip_address = true

  subnet_id = data.aws_subnet.saints-xctf-public-subnet-1.id
  security_groups = [module.bastion-subnet-security-group.security_group_id[0]]
  iam_instance_profile = aws_iam_instance_profile.bastion-instance-profile.name

  lifecycle {
    create_before_destroy = true
  }

  user_data = data.template_file.bastion-startup.rendered

  tags = {
    Name = "saints-xctf-bastion-host"
    Application = "saints-xctf"
  }

  depends_on = [null_resource.bastion-key-gen]
}

/* The instance profile assigns the RDS access IAM role to the bastion EC2 instance */
resource "aws_iam_instance_profile" "bastion-instance-profile" {
  name = "bastion-instance-profile"
  role = data.aws_iam_role.rds-access-role.name
}

/* Security group rules for the Bastion EC2 instance.  Most important is SSH access for the AWS admin */
module "bastion-subnet-security-group" {
  source = "github.com/ajarombek/terraform-modules//security-group?ref=v0.1.6"

  # Mandatory arguments
  name = "saints-xctf-bastion-security"
  tag_name = "saints-xctf-bastion-security-group"
  vpc_id = data.aws_vpc.saints-xctf-vpc.id

  # Optional arguments
  sg_rules = [
    {
      # Inbound traffic for SSH
      type = "ingress"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = local.my_cidr
    },
    {
      # Inbound traffic for ping
      type = "ingress"
      from_port = -1
      to_port = -1
      protocol = "icmp"
      cidr_blocks = local.public_cidr
    },
    {
      # Outbound traffic for HTTP
      type = "egress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = local.public_cidr
    },
    {
      # Outbound traffic for HTTP
      type = "egress"
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = local.public_cidr
    },
    {
      # Outbound traffic for MySQL
      type = "egress"
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      cidr_blocks = local.public_cidr
    },
  ]

  description = "SaintsXCTF Bastion Security Group"
}