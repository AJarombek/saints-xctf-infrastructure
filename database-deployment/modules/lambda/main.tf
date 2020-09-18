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

data "aws_iam_role" "lambda-role" {
  name = "saints-xctf-database-deployment-lambda-role"
}

data "archive_file" "lambda-zip" {
  source_dir = "${path.module}/func"
  output_path = "${path.module}/dist/lambda-${local.env}.zip"
  type = "zip"
}

#---------------------------------------------------------
# SaintsXCTF Database Deployment Lambda Function Resources
#---------------------------------------------------------

resource "aws_lambda_function" "rds-restore-lambda-function" {
  function_name = "SaintsXCTFDatabaseDeployment${upper(local.env)}"
  filename = "${path.module}/dist/lambda-${local.env}.zip"
  handler = "lambda.deploy"
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
    Name = "saints-xctf-${local.env}-database-deployment"
    Environment = upper(local.env)
    Application = "saints-xctf"
  }
}

resource "aws_lambda_alias" "rds-restore-lambda-alias" {
  name = "SaintsXCTFDatabaseDeploymentAlias${upper(local.env)}"
  description = "AWS Lambda function which deploys SQL scripts to an RDS database for SaintsXCTF."
  function_name = aws_lambda_function.rds-restore-lambda-function.function_name
  function_version = "$LATEST"
}

resource "aws_cloudwatch_log_group" "rds-restore-log-group" {
  name = "/aws/lambda/SaintsXCTFDatabaseDeployment${upper(local.env)}"
  retention_in_days = 7
}

module "security-group" {
  source = "github.com/ajarombek/terraform-modules//security-group?ref=v0.1.6"

  # Mandatory arguments
  name = "saints-xctf-${local.env}-database-deployment-security"
  tag_name = "saints-xctf-${local.env}-database-deployment-security"
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

  description = "SaintsXCTF RDS ${upper(local.env)} Database Deployment Lambda Function Security Group"
}