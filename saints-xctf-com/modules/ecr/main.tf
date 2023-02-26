/**
 * Docker image repositories in Elastic Container Registry for the SaintsXCTF application.
 * Author: Andrew Jarombek
 * Date: 7/13/2020
 */

resource "aws_ecr_repository" "saints-xctf-web-base-repository" {
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
}

resource "aws_ecr_repository" "saints-xctf-web-nginx-dev-repository" {
  name                 = "saints-xctf-web-nginx-dev"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "saints-xctf-web-nginx-dev-container-repository"
    Application = "saints-xctf"
    Environment = "development"
  }
}