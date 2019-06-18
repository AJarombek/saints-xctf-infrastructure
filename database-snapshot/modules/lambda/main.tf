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
  source_dir = "${path.module}/func"
  output_path = "${path.module}/dist/lambda-${local.env}.zip"
  type = "zip"

  depends_on = [null_resource.zip-lambda]
}

#--------------------------------------
# Executed Before Resources are Created
#--------------------------------------

resource "null_resource" "zip-lambda" {
  provisioner "local-exec" {
    command = "bash ${path.module}/zip-lambda.sh"
  }
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
  # source_code_hash = filebase64sha256(data.archive_file.lambda.output_path)

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

resource "aws_iam_policy" "lambda-secrets-manager-policy" {
  name = "lambda-secrets-manager-policy"
  path = "/saintsxctf/"
  policy = file("${path.module}/secrets-manager-policy.json")
}

resource "aws_iam_role_policy_attachment" "lambda-role-policy-attachment" {
  policy_arn = aws_iam_policy.lambda-secrets-manager-policy.arn
  role = aws_iam_role.lambda-role.name
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