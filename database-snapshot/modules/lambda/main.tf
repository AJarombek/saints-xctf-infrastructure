/**
 * Infrastructure for the saintsxctf RDS database backup lambda function
 * Author: Andrew Jarombek
 * Date: 6/7/2019
 */

locals {
  env = var.prod ? "prod" : "dev"
}

#-------------------
# Existing Resources
#-------------------

data "archive_file" "lambda" {
  source_file = "lambda.py"
  output_path = "dist/lambda-${local.env}.zip"
  type = "zip"
}

#-----------------------------------
# SaintsXCTF MySQL Secrets Resources
#-----------------------------------

resource "aws_secretsmanager_secret" "saints-xctf-rds-secret" {
  name = "saints-xctf-rds-${local.env}-secret"
  description = "SaintsXCTF MySQL RDS Login Credentials for the ${upper(local.env)} Environment"

  tags {
    Name = "saints-xctf-rds-${local.env}-secret"
    Environment = upper(local.env)
    Application = "saints-xctf"
  }
}

resource "aws_secretsmanager_secret_version" "saints-xctf-rds-secret-version" {
  secret_id = aws_secretsmanager_secret.saints-xctf-rds-secret.id
  secret_string = jsonencode(var.secrets)
}

#--------------------------------------------------
# SaintsXCTF MySQL Backup Lambda Function Resources
#--------------------------------------------------

resource "aws_lambda_function" "rds-backup-lambda-function" {
  function_name = "${upper(local.env)}SaintsXCTFbackup"
  filename = "lambda-${local.env}.zip"
  handler = "lambda.take_backup"
  role = aws_iam_role.lambda-role.arn
  runtime = "python3.7"
  source_code_hash = base64sha256(file(data.archive_file.lambda.output_path))

  environment {
    variables = {
      ENV = local.env
    }
  }

  tags = {
    Name = "saints-xctf-rds-${local.env}-backup"
    Environment = upper(local.env)
    Application = "saints-xctf"
  }
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

resource "aws_cloudwatch_event_rule" "lambda-function-schedule-rule" {
  name = "saints-xctf-rds-${local.env}-backup-lambda-rule"
  description = "Execute the Lambda Function Daily"
  schedule_expression = "rate(5 minutes)" # "cron(0 7 * * * *)"
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