/**
 * Infrastructure for the SaintsXCTF RDS database deployment lambda function
 * Author: Andrew Jarombek
 * Date: 6/7/2020
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

data "aws_db_instance" "saints-xctf-mysql-database" {
  db_instance_identifier = "saints-xctf-mysql-database-${local.env}"
}

#---------------------------------------------------------
# SaintsXCTF Database Deployment Lambda Function Resources
#---------------------------------------------------------