/**
 * Infrastructure for saintsxctf.com on Kubernetes in the development environment
 * Author: Andrew Jarombek
 * Date: 5/17/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = ">= 3.7.0"
     kubernetes = ">= 2.0.2"
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/saints-xctf-com/env/dev"
    region = "us-east-1"
  }
}

module "kubernetes" {
  source = "../../modules/kubernetes"
  prod = false
}