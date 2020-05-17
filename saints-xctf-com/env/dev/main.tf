/**
 * Infrastructure for V2 of the saintsxctf.com ECS/EKS cluster in the DEV environment
 * Author: Andrew Jarombek
 * Date: 5/17/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "jarombek-com-infrastructure/saints-xctf-com/env/dev"
    region = "us-east-1"
  }
}

module "alb" {
  source = "../../modules/alb"
  enabled = true
}

module "ecs" {
  source = "../../modules/ecs"
  enabled = true
}

module "eks" {
  source = "../../modules/eks"
  enabled = false
}