/**
 * Infrastructure for the SaintsXCTF API Gateway endpoints and Lambda functions in the PROD environment.
 * Author: Andrew Jarombek
 * Date: 5/24/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.13"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/saints-xctf-com-fn/env/prod"
    region = "us-east-1"
  }
}

module "email-lambda" {
  source = "../../modules/email-lambda"
  prod = true
}

module "uasset-lambda" {
  source = "../../modules/uasset-lambda"
  prod = true
}

module "api-gateway" {
  source = "../../modules/api-gateway"
  prod = true
  email-lambda-name = module.email-lambda.function-name
  email-lambda-invoke-arn = module.email-lambda.function-invoke-arn
  uasset-user-lambda-invoke-arn = module.uasset-lambda.user-function-invoke-arn
  uasset-user-lambda-name = module.uasset-lambda.user-function-name
}