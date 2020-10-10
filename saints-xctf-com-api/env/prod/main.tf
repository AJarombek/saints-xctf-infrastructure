/**
 * Infrastructure for api.saintsxctf.com on Kubernetes in the production environment
 * Author: Andrew Jarombek
 * Date: 7/13/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.66.0"
    kubernetes = ">= 1.11"
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/saints-xctf-com/env/prod"
    region = "us-east-1"
  }
}

module "kubernetes" {
  source = "../../modules/kubernetes"
  prod = true
}