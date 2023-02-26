/**
 * Infrastructure for the SaintsXCTF API Gateway endpoints and Lambda functions for authentication in the PROD environment.
 * Author: Andrew Jarombek
 * Date: 5/28/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.42.0"
    }
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "saints-xctf-infrastructure/saints-xctf-com-auth/env/prod"
    region  = "us-east-1"
  }
}

module "lambda" {
  source = "../../modules/lambda"
  prod   = true
}

module "api-gateway" {
  source = "../../modules/api-gateway"
  prod   = true

  authenticate-lambda-name       = module.lambda.authenticate-function-name
  authenticate-lambda-invoke-arn = module.lambda.authenticate-function-invoke-arn
  token-lambda-name              = module.lambda.token-function-name
  token-lambda-invoke-arn        = module.lambda.token-function-invoke-arn
}

module "secrets-manager" {
  source = "../../modules/secrets-manager"
  prod   = true

  rotation-lambda-arn = module.lambda.rotate-function-arn

  secret_rotation_depends_on = [
    module.lambda.rotate-function-arn,
    module.lambda.rotate-secrets-manager-permission-id,
    module.lambda.rotate-log-group-id
  ]
}