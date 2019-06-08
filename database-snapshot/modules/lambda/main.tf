/**
 * Infrastructure for the saintsxctf RDS database snapshot lambda function
 * Author: Andrew Jarombek
 * Date: 6/7/2019
 */

locals {
  env = var.prod ? "prod" : "dev"
}

data "archive_file" "lambda" {
  source_file = "lambda.py"
  output_path = "dist/lambda-${local.env}.zip"
  type = "zip"
}