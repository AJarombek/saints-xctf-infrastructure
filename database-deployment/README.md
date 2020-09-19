### Overview

These subdirectories contain all the Terraform scripts needed to create an S3 bucket and lambda function for deploying
scripts to a MySQL database.

### Directories

| Directory Name    | Description                                                                                           |
|-------------------|-------------------------------------------------------------------------------------------------------|
| `env`             | Code to build infrastructure in specific environments, and infrastructure shared by all environments. |
| `modules`         | Modules for building an S3 bucket and Lambda function for database deployments.                       |
