/**
 * Infrastructure needed in the SaintsXCTF VPC for the lambda backup function to work.
 * Author: Andrew Jarombek
 * Date: 9/1/2019
 */

locals {
  public_cidr = "0.0.0.0/0"
}

#-------------------
# Existing Resources
#-------------------

data "aws_vpc" "application-vpc" {
  tags = {
    Name = "application-vpc"
  }
}

data "aws_subnet" "application-vpc-public-subnet-0" {
  tags = {
    Name = "saints-xctf-com-lisag-public-subnet"
  }
}

data "aws_subnet" "application-vpc-public-subnet-1" {
  tags = {
    Name = "saints-xctf-com-megank-public-subnet"
  }
}

data "aws_route_table" "saints-xctf-com-route-table-public" {
  tags = {
    Name = "application-vpc-public-subnet-rt"
  }
}

#----------------------------------
# SaintsXCTF VPC Endpoint Resources
#----------------------------------

resource "aws_vpc_endpoint" "saints-xctf-secrets-manager-vpc-endpoint" {
  vpc_id            = data.aws_vpc.application-vpc.id
  service_name      = "com.amazonaws.us-east-1.secretsmanager"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    data.aws_subnet.application-vpc-public-subnet-0.id,
    data.aws_subnet.application-vpc-public-subnet-1.id
  ]

  security_group_ids  = [module.vpc-endpoint-security-group.security_group_id[0]]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "saints-xctf-s3-vpc-endpoint" {
  vpc_id            = data.aws_vpc.application-vpc.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    data.aws_route_table.saints-xctf-com-route-table-public.id
  ]
}

module "vpc-endpoint-security-group" {
  source = "github.com/ajarombek/terraform-modules//security-group?ref=v0.1.6"

  # Mandatory arguments
  name     = "saints-xctf-vpc-endpoint-security"
  tag_name = "saints-xctf-vpc-endpoint-security"
  vpc_id   = data.aws_vpc.application-vpc.id

  # Optional arguments
  sg_rules = [
    {
      # All Inbound traffic
      type        = "ingress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = local.public_cidr
    },
    {
      # All Outbound traffic
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = local.public_cidr
    }
  ]

  description = "SaintsXCTF VPC Endpoint Security Group"
}