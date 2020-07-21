/**
 * Infrastructure for the saintsxctf RDS database backup lambda function
 * Author: Andrew Jarombek
 * Date: 6/7/2019
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

data "archive_file" "backup-lambda" {
  source_dir = "${path.module}/func/backup"
  output_path = "${path.module}/dist/backup-lambda-${local.env}.zip"
  type = "zip"
}

data "archive_file" "restore-lambda" {
  source_dir = "${path.module}/func/restore"
  output_path = "${path.module}/dist/restore-lambda-${local.env}.zip"
  type = "zip"
}

data "aws_iam_role" "lambda-role" {
  name = "saints-xctf-rds-backup-lambda-role"
}

#---------------------------------------------------
# SaintsXCTF MySQL Restore Lambda Function Resources
#---------------------------------------------------

resource "aws_lambda_function" "rds-restore-lambda-function" {
  function_name = "SaintsXCTFMySQLRestore${upper(local.env)}"
  filename = "${path.module}/dist/restore-lambda-${local.env}.zip"
  handler = "lambda.restore"
  role = data.aws_iam_role.lambda-role.arn
  runtime = "python3.8"
  timeout = 15

  environment {
    variables = {
      ENV = local.env
      DB_HOST = data.aws_db_instance.saints-xctf-mysql-database.address
    }
  }

  vpc_config {
    security_group_ids = [module.security-group.security_group_id[0]]
    subnet_ids = [
      data.aws_subnet.saints-xctf-com-vpc-public-subnet-0.id,
      data.aws_subnet.saints-xctf-com-vpc-public-subnet-1.id
    ]
  }

  tags = {
    Name = "saints-xctf-rds-${local.env}-restore"
    Environment = upper(local.env)
    Application = "saints-xctf"
  }
}

resource "aws_lambda_alias" "rds-restore-lambda-alias" {
  name = "SaintsXCTFMySQLRestoreAlias${upper(local.env)}"
  description = "AWS Lambda function which restores a MySQL database from a backup"
  function_name = aws_lambda_function.rds-restore-lambda-function.function_name
  function_version = "$LATEST"
}

resource "aws_cloudwatch_log_group" "rds-restore-log-group" {
  name = "/aws/lambda/SaintsXCTFMySQLRestore${upper(local.env)}"
  retention_in_days = 7
}

#--------------------------------------------------
# SaintsXCTF MySQL Backup Lambda Function Resources
#--------------------------------------------------

resource "aws_lambda_function" "rds-backup-lambda-function" {
  function_name = "SaintsXCTFMySQLBackup${upper(local.env)}"
  filename = "${path.module}/dist/backup-lambda-${local.env}.zip"
  handler = "lambda.create_backup"
  role = data.aws_iam_role.lambda-role.arn
  runtime = "python3.7"
  timeout = 15

  environment {
    variables = {
      ENV = local.env
      DB_HOST = data.aws_db_instance.saints-xctf-mysql-database.address
    }
  }

  vpc_config {
    security_group_ids = [module.security-group.security_group_id[0]]
    subnet_ids = [
      data.aws_subnet.saints-xctf-com-vpc-public-subnet-0.id,
      data.aws_subnet.saints-xctf-com-vpc-public-subnet-1.id
    ]
  }

  tags = {
    Name = "saints-xctf-rds-${local.env}-backup"
    Environment = upper(local.env)
    Application = "saints-xctf"
  }
}

resource "aws_lambda_alias" "rds-backup-lambda-alias" {
  name = "SaintsXCTFMySQLBackupAlias${upper(local.env)}"
  description = "AWS Lambda function which creates MySQL database backups"
  function_name = aws_lambda_function.rds-backup-lambda-function.function_name
  function_version = "$LATEST"
}

resource "aws_cloudwatch_log_group" "rds-backup-log-group" {
  name = "/aws/lambda/SaintsXCTFMySQLBackup${upper(local.env)}"
  retention_in_days = 7
}

resource "aws_cloudwatch_event_rule" "lambda-function-schedule-rule" {
  name = "saints-xctf-rds-${local.env}-backup-lambda-rule"
  description = "Execute the Lambda Function Daily"
  schedule_expression = "cron(0 7 * * ? *)"
  is_enabled = true

  tags = {
    Name = "saints-xctf-rds-${local.env}-backup-lambda-rule"
    Environment = upper(local.env)
    Application = "saints-xctf"
  }
}

resource "aws_cloudwatch_event_target" "lambda-function-schedule-target" {
  arn = aws_lambda_function.rds-backup-lambda-function.arn
  rule = aws_cloudwatch_event_rule.lambda-function-schedule-rule.name
}

resource "aws_lambda_permission" "lambda-function-schedule-permission" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds-backup-lambda-function.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.lambda-function-schedule-rule.arn
}

module "security-group" {
  source = "github.com/ajarombek/terraform-modules//security-group?ref=v0.1.6"

  # Mandatory arguments
  name = "saints-xctf-lambda-rds-backup-security-${local.env}"
  tag_name = "saints-xctf-lambda-rds-backup-security-${local.env}"
  vpc_id = data.aws_vpc.saints-xctf-com-vpc.id

  # Optional arguments
  sg_rules = [
    {
      # All Inbound traffic
      type = "ingress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = local.public_cidr
    },
    {
      # All Outbound traffic
      type = "egress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = local.public_cidr
    }
  ]

  description = "SaintsXCTF RDS ${upper(local.env)} Backup Lambda Function Security Group"
}