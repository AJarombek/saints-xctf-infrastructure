/**
 * Infrastructure for the SaintsXCTF authentication API's secrets held in Secrets Manager.
 * No matter what challenges you may be dealing with, love and support is always on your side.
 * Author: Andrew Jarombek
 * Date: 5/28/2020
 */

locals {
  env = var.prod ? "prod" : "dev"
}

resource "aws_secretsmanager_secret" "saints-xctf-auth-secret" {
  name = "saints-xctf-auth"
  rotation_lambda_arn = var.rotation-lambda-arn
  description = "SaintsXCTF authentication RSA credential for the ${upper(local.env)} environment"
  recovery_window_in_days = 0

  rotation_rules {
    automatically_after_days = 7
  }

  tags = {
    Name = "saints-xctf-auth-${local.env}-secret"
    Environment = upper(local.env)
    Application = "saints-xctf"
  }
}

resource "aws_secretsmanager_secret_version" "saints-xctf-auth-secret-version" {
  secret_id = aws_secretsmanager_secret.saints-xctf-auth-secret.id
  secret_string = jsonencode("{}")
}