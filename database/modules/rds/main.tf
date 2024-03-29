/**
 * Infrastructure for the MySQL saintsxctf database
 * Author: Andrew Jarombek
 * Date: 12/3/2018
 */

locals {
  env                   = var.prod ? "prod" : "dev"
  subnet_number         = var.prod ? 0 : 1
  backups_retained_days = var.prod ? 3 : 0
  db_identifier         = "saints-xctf-mysql-database-${local.env}"
}

#----------------------------------
# Existing SaintsXCTF VPC Resources
#----------------------------------

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

data "aws_subnet" "application-vpc-public-subnet-2" {
  tags = {
    Name = "kubernetes-grandmas-blanket-public-subnet"
  }
}

data "aws_subnet" "application-vpc-public-subnet-3" {
  tags = {
    Name = "kubernetes-dotty-public-subnet"
  }
}

data "aws_subnet" "application-vpc-private-subnet-0" {
  tags = {
    Name = "saints-xctf-com-cassiah-private-subnet"
  }
}

data "aws_subnet" "application-vpc-private-subnet-1" {
  tags = {
    Name = "saints-xctf-com-carolined-private-subnet"
  }
}

#------------------------------------
# SaintsXCTF MySQL Database Resources
#------------------------------------

/* The MySQL security group allows incoming traffic on the database port (3306) from the public subnets */
resource "aws_security_group" "saints-xctf-database-security" {
  name        = "saints-xctf-database-security-${local.env}"
  description = "Allow incoming traffic to the MySQL port"
  vpc_id      = data.aws_vpc.application-vpc.id

  ingress {
    protocol  = "tcp"
    from_port = 3306
    to_port   = 3306
    cidr_blocks = [
      data.aws_subnet.application-vpc-public-subnet-0.cidr_block,
      data.aws_subnet.application-vpc-public-subnet-1.cidr_block,
      data.aws_subnet.application-vpc-public-subnet-2.cidr_block,
      data.aws_subnet.application-vpc-public-subnet-3.cidr_block,
      data.aws_subnet.application-vpc-private-subnet-0.cidr_block,
      data.aws_subnet.application-vpc-private-subnet-1.cidr_block
    ]
  }

  tags = {
    Name        = "saints-xctf-database-security-${local.env}"
    Environment = upper(local.env)
    Application = "saints-xctf"
    Terraform   = var.terraform_tag
  }
}

resource "aws_db_instance" "saints-xctf-mysql-database" {
  identifier     = local.db_identifier
  instance_class = "db.t2.micro"
  engine         = "MySQL"
  engine_version = "8.0.36"

  allocated_storage       = 5
  backup_retention_period = local.backups_retained_days
  storage_type            = "gp2"
  storage_encrypted       = false
  backup_window           = "07:00-08:00"

  # When updating, wait for the maintenance window
  apply_immediately         = false
  maintenance_window        = "Mon:04:00-Mon:07:00"
  final_snapshot_identifier = "saintsxctf-${local.env}"

  db_name  = "saintsxctf"
  username = var.username
  password = var.password
  port     = 3306

  # Allow resources to access the DB instance via IAM policies instead of usernames/passwords.
  # IAM authentication is not available on small instance sizes.
  iam_database_authentication_enabled = true

  vpc_security_group_ids = [aws_security_group.saints-xctf-database-security.id]
  db_subnet_group_name   = aws_db_subnet_group.saints-xctf-mysql-database-subnet.name
  publicly_accessible    = false

  # Enables HA for the database instance
  multi_az = true

  deletion_protection = true
  skip_final_snapshot = false

  tags = {
    Name        = "saints-xctf-mysql-${local.env}-database"
    Environment = upper(local.env)
    Application = "saints-xctf"
    Terraform   = var.terraform_tag
  }
}

/* The subnets to use for a highly available database */
resource "aws_db_subnet_group" "saints-xctf-mysql-database-subnet" {
  subnet_ids = [
    data.aws_subnet.application-vpc-private-subnet-0.id,
    data.aws_subnet.application-vpc-private-subnet-1.id
  ]

  tags = {
    Name        = "saints-xctf-mysql-${local.env}-database-subnets"
    Environment = upper(local.env)
    Application = "saints-xctf"
    Terraform   = var.terraform_tag
  }
}

/* An alarm is set up in case the database is running out of storage space.  This will signal an upgrade is needed. */
resource "aws_cloudwatch_metric_alarm" "saints-xctf-mysql-database-storage-low-alarm" {
  alarm_name        = "saints-xctf-mysql-${var.prod ? "prod" : "dev"}-database-storage-low-alarm"
  alarm_description = "Monitors if the SaintsXCTF MySQL Database is running low on storage in ${upper(local.env)}"

  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  comparison_operator = "LessThanThreshold"

  # The number of periods where data is compared to the threshold
  evaluation_periods = 2

  # The number of seconds that the statistic is applied
  period    = 120
  statistic = "Average"

  # The value that trips the alarm
  threshold = 20

  dimensions = {
    DBInstanceIdentifier = local.db_identifier
  }
}