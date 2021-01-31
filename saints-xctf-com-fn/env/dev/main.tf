/**
 * Infrastructure for the SaintsXCTF API Gateway endpoints and Lambda functions in the DEV environment.
 * Author: Andrew Jarombek
 * Date: 5/24/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.13.5"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.16.0"
    }
    template = {
      source = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/saints-xctf-com-fn/env/dev"
    region = "us-east-1"
  }
}

module "email-lambda" {
  source = "../../modules/email-lambda"
  prod = false
}

module "uasset-lambda" {
  source = "../../modules/uasset-lambda"
  prod = false
}

module "api-gateway" {
  source = "../../modules/api-gateway"
  prod = false
  email-lambda-name = module.email-lambda.forgot-password-function-name
  email-lambda-invoke-arn = module.email-lambda.forgot-password-function-invoke-arn
  email-activation-code-lambda-name = module.email-lambda.activation-code-function-name
  email-activation-code-lambda-invoke-arn = module.email-lambda.activation-code-invoke-arn
  email-welcome-lambda-name = module.email-lambda.welcome-function-name
  email-welcome-lambda-invoke-arn = module.email-lambda.welcome-invoke-arn
  uasset-user-lambda-name = module.uasset-lambda.uasset-user-function-name
  uasset-user-lambda-invoke-arn = module.uasset-lambda.uasset-user-function-invoke-arn
  uasset-group-lambda-name = module.uasset-lambda.uasset-group-function-name
  uasset-group-lambda-invoke-arn = module.uasset-lambda.uasset-group-function-invoke-arn
}