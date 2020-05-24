/**
 * Infrastructure for V2 of the saintsxctf.com ECS/EKS cluster in the PROD environment
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
    key = "jarombek-com-infrastructure/saints-xctf-com/env/prod"
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