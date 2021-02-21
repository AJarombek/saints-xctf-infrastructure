/**
 * Infrastructure for an Ingress object used by both api.saintsxctf.com and saintsxctf.com on Kubernetes in the
 * development environment
 * Author: Andrew Jarombek
 * Date: 10/9/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = ">= 3.6.0"
    kubernetes = ">= 2.0.2"
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/saints-xctf-com-ingress/env/dev"
    region = "us-east-1"
  }
}

module "kubernetes" {
  source = "../../modules/kubernetes"
  prod = false
}