/**
 * Infrastructure for the MySQL saintsxctf database
 * Author: Andrew Jarombek
 * Date: 12/3/2018
 */

locals {
  env = "${var.prod ? "prod" : "dev"}"
  subnet_number = "${var.prod ? 0 : 1}"
  backups_retained_days = "${var.prod ? 3 : 0}"
}

#----------------------------------
# Existing SaintsXCTF VPC Resources
#----------------------------------

data "aws_vpc" "saints-xctf-com-vpc" {
  tags {
    Name = "SaintsXCTFcom VPC"
  }
}

data "aws_subnet" "saints-xctf-com-vpc-public-subnet-0" {
  tags {
    Name = "SaintsXCTFcom VPC Public Subnet 0"
  }
}

data "aws_subnet" "saints-xctf-com-vpc-public-subnet-1" {
  tags {
    Name = "SaintsXCTFcom VPC Public Subnet 1"
  }
}

data "aws_subnet" "saints-xctf-com-vpc-private-subnet-0" {
  tags {
    Name = "SaintsXCTFcom VPC Private Subnet 0"
  }
}

data "aws_subnet" "saints-xctf-com-vpc-private-subnet-1" {
  tags {
    Name = "SaintsXCTFcom VPC Private Subnet 1"
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
    cidr_blocks = [
      "${data.aws_subnet.saints-xctf-com-vpc-public-subnet-0.cidr_block}",
      "${data.aws_subnet.saints-xctf-com-vpc-public-subnet-1.cidr_block}"
    ]
  }

  tags {
    Name = "saints-xctf-database-security-${local.env}"
  }
}

resource "aws_db_instance" "saints-xctf-mysql-database" {
  identifier = "saints-xctf-mysql-database-${local.env}"
  instance_class = "db.t2.micro"
  engine = "MySQL"
  engine_version = "5.7.19"

  allocated_storage = 5
  backup_retention_period = "${local.backups_retained_days}"
  storage_type = "gp2"
  storage_encrypted = false
  backup_window = "07:00-08:00"

  # When updating, wait for the maintenance window
  apply_immediately = false
  maintenance_window = "Mon:04:00-Mon:07:00"
  final_snapshot_identifier = "saintsxctf-${local.env}"

  name = "saintsxctf"
  username = "${var.username}"
  password = "${var.password}"
  port = 3306

  # Allow resources to access the DB instance via IAM policies instead of usernames/passwords.
  # IAM authentication is not available on small instance sizes.
  iam_database_authentication_enabled = true

  vpc_security_group_ids = ["${aws_security_group.saints-xctf-database-security.id}"]
  db_subnet_group_name = "${aws_db_subnet_group.saints-xctf-mysql-database-subnet.name}"
  publicly_accessible = false

  # Enables HA for the database instance
  multi_az = true

  tags {
    Name = "Saints-xctf-mysql-${local.env}-database"
    Environment = "${upper(local.env)}"
  }
}

resource "aws_db_subnet_group" "saints-xctf-mysql-database-subnet" {
  subnet_ids = [
    "${data.aws_subnet.saints-xctf-com-vpc-private-subnet-0.id}",
    "${data.aws_subnet.saints-xctf-com-vpc-private-subnet-1.id}"
  ]

  tags {
    Name = "saints-xctf-mysql-${local.env}-database-subnets"
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