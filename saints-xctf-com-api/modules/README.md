### Overview

Terraform modules needed to build infrastructure for the SaintsXCTF API.

### Directories

| Directory Name    | Description                                                                            |
|-------------------|----------------------------------------------------------------------------------------|
| `ecr`             | Terraform module to build an ECR repository.                                           |
| `kubernetes`      | Terraform module to build Kubernetes objects and an ALB which makes them accessible.   |