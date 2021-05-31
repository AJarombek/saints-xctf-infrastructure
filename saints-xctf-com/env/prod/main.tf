/**
 * Infrastructure for saintsxctf.com on Kubernetes in the production environment
 * Author: Andrew Jarombek
 * Date: 7/13/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.15"

  required_providers {
    aws = ">= 3.42.0"
    kubernetes = ">= 2.0.2"
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