/**
 * Infrastructure for the SaintsXCTF API Gateway endpoints and Lambda functions for authentication in the PROD environment.
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
    key = "saints-xctf-infrastructure/saints-xctf-com-auth/env/prod"
    region = "us-east-1"
  }
}

module "lambda" {
  source = "../../modules/lambda"
  prod = true
}

module "api-gateway" {
  source = "../../modules/api-gateway"
  prod = true
  rotation-lambda-name = module.lambda.function-name
  rotation-lambda-invoke-arn = module.lambda.function-invoke-arn
}

module "secrets-manager" {
  source = "../../modules/secrets-manager"
  prod = true
}