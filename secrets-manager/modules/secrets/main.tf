/**
 * Infrastructure for the SaintsXCTF Secrets Manager
 * Author: Andrew Jarombek
 * Date: 6/14/2019
 */

locals {
  env = var.prod ? "prod" : "dev"
  public_cidr = "0.0.0.0/0"
}

#-------------------
# Existing Resources
#-------------------

data "aws_vpc" "saints-xctf-com-vpc" {
  tags = {
    Name = "saints-xctf-com-vpc"
  }
}

data "aws_subnet" "saints-xctf-com-vpc-public-subnet-0" {
  tags = {
    Name = "saints-xctf-com-lisag-public-subnet"
  }
}

data "aws_subnet" "saints-xctf-com-vpc-public-subnet-1" {
  tags = {
    Name = "saints-xctf-com-megank-public-subnet"
  }
}

#-----------------------------------
# SaintsXCTF MySQL Secrets Resources
#-----------------------------------

resource "aws_secretsmanager_secret" "saints-xctf-rds-secret" {
  name = "saints-xctf-rds-${local.env}-secret"
  description = "SaintsXCTF MySQL RDS Login Credentials for the ${upper(local.env)} Environment"

  tags = {
    Name = "saints-xctf-rds-${local.env}-secret"
    Environment = upper(local.env)
    Application = "saints-xctf"
  }
}

resource "aws_secretsmanager_secret_version" "saints-xctf-rds-secret-version" {
  secret_id = aws_secretsmanager_secret.saints-xctf-rds-secret.id
  secret_string = jsonencode(var.rds_secrets)
}