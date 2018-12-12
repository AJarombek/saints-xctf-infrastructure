/**
 * Infrastructure for the MySQL saintsxctf database
 * Author: Andrew Jarombek
 * Date: 12/3/2018
 */

locals {
  env = "${var.prod ? "prod" : "dev"}"
}

#----------------------------------
# Existing SaintsXCTF VPC Resources
#----------------------------------

data "aws_vpc" "saints-xctf-com-vpc" {
  tags {
    Name = "SaintsXCTFcom VPC"
  }
}

data "aws_subnet" "saints-xctf-com-vpc-public-subnet" {
  tags {
    Name = "SaintsXCTFcom VPC Public Subnet"
  }
}

data "aws_subnet" "saints-xctf-com-vpc-private-subnet" {
  tags {
    Name = "SaintsXCTFcom VPC Private Subnet"
  }
}

data "aws_security_group" "saints-xctf-website-security" {
  tags {
    Name = "SaintsXCTFcom ${upper(local.env)} Website Security"
  }
}

#------------------------------------
# SaintsXCTF MySQL Database Resources
#------------------------------------

resource "aws_security_group" "saints-xctf-database-security" {
  name = "saints-xctf-database-security-${local.env}"
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
    Name = "SaintsXCTFcom MySQL ${upper(local.env)} Database Security"
  }
}

resource "aws_db_instance" "saints-xctf-mysql-database" {
  instance_class = "db.t2.micro"
  name = "saintsxctf"
  engine = "MySQL"
  allocated_storage = 5
  backup_retention_period = 3
  storage_type = "gp2"
  backup_window = "06:00-07:00"
  username = "${var.username}"
  password = "${var.password}"
  vpc_security_group_ids = ["${aws_security_group.saints-xctf-database-security.id}"]

  # Enables HA for the database instance
  multi_az = true

  tags {
    Name = "SaintsXCTFcom MySQL ${upper(local.env)} Database"
  }
}

resource "aws_db_subnet_group" "saints-xctf-mysql-database-subnet" {
  subnet_ids = ["${data.aws_subnet.saints-xctf-com-vpc-private-subnet}"]

  tags {
    Name = "SaintsXCTFcom MySQL ${upper(local.env)} Database Subnets"
  }
}

resource "aws_cloudwatch_metric_alarm" "saints-xctf-mysql-database-storage-low-alarm" {
  alarm_name = "saints-xctf-mysql-${var.prod ? "prod" : "dev"}-database-storage-low-alarm"
  alarm_description = "Monitors if the SaintsXCTF MySQL Database is running low on storage in ${upper(local.env)}"

  metric_name = "FreeStorageSpace"
  namespace = "AWS/RDS"
  comparison_operator = "LessThanThreshold"

  # The number of periods where data is compared to the threshold
  evaluation_periods = 2

  # The number of seconds that the statistic is applied
  period = 120
  statistic = "Average"

  # The value that trips the alarm
  threshold = 20

  dimensions {
    DBInstanceIdentifier = "${aws_db_instance.saints-xctf-mysql-database.id}"
  }
}