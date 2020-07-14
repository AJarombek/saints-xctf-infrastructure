/**
 * Docker image repositories in Elastic Container Registry for the SaintsXCTF API application.
 * Author: Andrew Jarombek
 * Date: 7/13/2020
 */

resource "aws_ecr_repository" "saints-xctf-api-repository" {
  name = "saints-xctf-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "saints-xctf-api-container-repository"
    Application = "all"
    Environment = "all"
  }
}