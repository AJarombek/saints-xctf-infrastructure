/**
 * V3 infrastructure for the api.saintsxctf.com application.
 * Author: Andrew Jarombek
 * Date: 1/13/2024
 */

terraform {
  required_version = "~> 1.6.6"

  required_providers {
    aws = ">= 5.32.1"
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "saints-xctf-infrastructure/api"
    region  = "us-east-1"
  }
}

/*resource "aws_ecr_repository" "saints-xctf-web-base-repository" {
  name                 = "saints-xctf-web-base"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "saints-xctf-web-base-container-repository"
    Application = "saints-xctf"
    Environment = "all"
  }
}

resource "aws_ecr_repository" "saints-xctf-web-nginx-repository" {
  name                 = "saints-xctf-web-nginx"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "saints-xctf-web-nginx-container-repository"
    Application = "saints-xctf"
    Environment = "production"
  }
}*/
