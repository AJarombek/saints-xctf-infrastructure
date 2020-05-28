/**
 * Infrastructure for the SaintsXCTF API Gateway endpoints and Lambda functions for authentication in the DEV environment.
 * Author: Andrew Jarombek
 * Date: 5/28/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/saints-xctf-com-auth/env/dev"
    region = "us-east-1"
  }
}

module "lambda" {
  source = "../../modules/lambda"
  prod = false
}

module "api-gateway" {
  source = "../../modules/api-gateway"
  prod = false
  rotation-lambda-name = module.lambda.function-name
  rotation-lambda-invoke-arn = module.lambda.function-invoke-arn
}

module "secrets-manager" {
  source = "../../modules/secrets-manager"
  prod = false
}