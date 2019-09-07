/**
 * Infrastructure for the SaintsXCTF Secrets Manager
 * Author: Andrew Jarombek
 * Date: 6/14/2019
 */

locals {
  env = var.prod ? "prod" : "dev"
}

#-----------------------------------
# SaintsXCTF MySQL Secrets Resources
#-----------------------------------

resource "aws_secretsmanager_secret" "saints-xctf-rds-secret" {
  name = "saints-xctf-rds-${local.env}-secret"
  description = "SaintsXCTF MySQL RDS Login Credentials for the ${upper(local.env)} Environment"

  tags = {
    Name = "saints-xctf-rds-${local.env}-secret"
    Environment = upper(local.env)
    Application = "saints-xctf"
  }
}

resource "aws_secretsmanager_secret_version" "saints-xctf-rds-secret-version" {
  secret_id = aws_secretsmanager_secret.saints-xctf-rds-secret.id
  secret_string = jsonencode(var.rds_secrets)
}