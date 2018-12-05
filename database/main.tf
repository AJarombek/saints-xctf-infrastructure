/**
 * Infrastructure for the MySQL saintsxctf database
 * Author: Andrew Jarombek
 * Date: 12/3/2018
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/database"
    region = "us-east-1"
  }
}

#----------------------------------
# Existing SaintsXCTF VPC Resources
#----------------------------------

data "aws_vpc" "saints-xctf-com-vpc" {
  tags {
    Name = "SaintsXCTFCom VPC"
  }
}

data "aws_subnet" "saints-xctf-com-vpc-public-subnet" {
  tags {
    Name = "SaintsXCTFCom VPC Public Subnet"
  }
}

data "aws_subnet" "saints-xctf-com-vpc-private-subnet" {
  tags {
    Name = "SaintsXCTFCom VPC Private Subnet"
  }
}

data "aws_security_group" "saints-xctf-website-security" {
  tags {
    Name = "SaintsXCTF Website Security"
  }
}

#------------------------------------
# SaintsXCTF MySQL Database Resources
#------------------------------------

resource "aws_security_group" "saints-xctf-database-security" {
  name = "saints-xctf-database-security"
  description = "Allow incoming traffic to the MySQL port"
  vpc_id = "${data.aws_vpc.saints-xctf-com-vpc.id}"

  ingress {
    protocol = "tcp"
    from_port = 3306
    to_port = 3306
    cidr_blocks = ["${data.aws_subnet.saints-xctf-com-vpc-public-subnet.cidr_block}"]
    security_groups = ["${data.aws_security_group.saints-xctf-website-security.id}"]
  }

  tags {
    Name = "SaintsXCTF MySQL Database Security"
  }
}

resource "aws_db_instance" "saints-xctf-mysql-database" {
  instance_class = "db.t2.micro"
  name = "saintsxctf"
  engine = "MySQL"
  allocated_storage = 5
  backup_retention_period = 0
}