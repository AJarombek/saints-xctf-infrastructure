### Overview

There is one module for creating a Lambda Function for RDS backups.  `lambda` creates an AWS Lambda function which is 
run once a day.

### Directories

| Directory Name    | Description                                                                   |
|-------------------|-------------------------------------------------------------------------------|
| `lambda`          | Terraform module for a Lambda Function for RDS backups.                       |
| `vpc-endpoints`   | Terraform module for VPC Endpoints exposing resources to the private subnets. |