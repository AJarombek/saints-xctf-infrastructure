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

module "lambda" {
  source = "../../modules/lambda"
  prod = false
}

module "api-lambda" {
  source = "../../modules/api-gateway"
  prod = false
}