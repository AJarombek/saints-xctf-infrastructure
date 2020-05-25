/**
 * Infrastructure for the SaintsXCTF API Gateway endpoints and Lambda functions in the PROD environment.
 * Author: Andrew Jarombek
 * Date: 5/24/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/fn-saints-xctf-com/env/prod"
    region = "us-east-1"
  }
}

module "email-lambda" {
  source = "../../modules/email-lambda"
  prod = false
}

module "auth-lambda" {
  source = "../../modules/auth-lambda"
  prod = false
}

module "api-gateway" {
  source = "../../modules/api-gateway"
  prod = true
  lambda-function-name = module.email-lambda.function-name
  lambda-function-invoke-arn = module.email-lambda.function-invoke-arn
}