/**
 * Infrastructure for api.saintsxctf.com on Kubernetes in the development environment
 * Author: Andrew Jarombek
 * Date: 7/13/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws        = ">= 2.66.0"
    kubernetes = ">= 2.0.2"
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "saints-xctf-infrastructure/saints-xctf-com-api/env/dev"
    region  = "us-east-1"
  }
}

module "kubernetes" {
  source = "../../modules/kubernetes"
  prod   = false
}