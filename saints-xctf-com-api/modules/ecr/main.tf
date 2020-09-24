/**
 * Docker image repositories in Elastic Container Registry for the SaintsXCTF API application.
 * Author: Andrew Jarombek
 * Date: 7/13/2020
 */

resource "aws_ecr_repository" "saints-xctf-api-flask-repository" {
  name = "saints-xctf-api-flask"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "saints-xctf-api-flask-container-repository"
    Application = "saints-xctf"
    Environment = "all"
  }
}

resource "aws_ecr_repository" "saints-xctf-api-nginx-repository" {
  name = "saints-xctf-api-nginx"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "saints-xctf-api-nginx-container-repository"
    Application = "saints-xctf"
    Environment = "all"
  }
}