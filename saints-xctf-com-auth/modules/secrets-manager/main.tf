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
  name = "saints-xctf-auth-secret"
  rotation_lambda_arn = var.rotation-lambda-invoke-arn
  description = "SaintsXCTF authentication RSA credential for the ${upper(local.env)} environment"

  rotation_rules {
    automatically_after_days = 7
  }

  tags = {
    Name = "saints-xctf-auth-${local.env}-secret"
    Environment = upper(local.env)
    Application = "saints-xctf"
  }
}