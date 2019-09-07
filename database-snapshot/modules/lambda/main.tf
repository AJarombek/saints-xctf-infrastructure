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

data "archive_file" "lambda" {
  source_dir = "${path.module}/func"
  output_path = "${path.module}/dist/lambda-${local.env}.zip"
  type = "zip"
}

#--------------------------------------------------
# SaintsXCTF MySQL Backup Lambda Function Resources
#--------------------------------------------------

resource "aws_lambda_function" "rds-backup-lambda-function" {
  function_name = "SaintsXCTFMySQLBackup${upper(local.env)}"
  filename = "${path.module}/dist/lambda-${local.env}.zip"
  handler = "lambda.create_backup"
  role = aws_iam_role.lambda-role.arn
  runtime = "python3.7"
  timeout = 15

  environment {
    variables = {
      ENV = local.env
      DB_HOST = data.aws_db_instance.saints-xctf-mysql-database.address
    }
  }

  vpc_config {
    security_group_ids = [module.lambda-rds-backup-security-group.security_group_id[0]]
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

resource "aws_iam_role" "lambda-role" {
  name = "saints-xctf-rds-backup-lambda-role"
  assume_role_policy = file("${path.module}/role.json")

  tags = {
    Name = "saints-xctf-rds-backup-lambda-role"
    Environment = "all"
    Application = "saints-xctf"
  }
}

resource "aws_iam_policy" "rds-backup-lambda-policy" {
  name = "rds-backup-lambda-policy"
  path = "/saintsxctf/"
  policy = file("${path.module}/rds-backup-lambda-policy.json")
}

resource "aws_iam_role_policy_attachment" "lambda-role-policy-attachment" {
  policy_arn = aws_iam_policy.rds-backup-lambda-policy.arn
  role = aws_iam_role.lambda-role.name
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

module "lambda-rds-backup-security-group" {
  source = "github.com/ajarombek/terraform-modules//security-group?ref=v0.1.6"

  # Mandatory arguments
  name = "saints-xctf-lambda-rds-backup-security"
  tag_name = "saints-xctf-lambda-rds-backup-security"
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

  description = "SaintsXCTF RDS Backup Lambda Function Security Group"
}