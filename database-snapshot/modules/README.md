### Overview

There is one module for creating a Lambda Function for RDS backups.  `lambda` creates an AWS Lambda function which is 
run once a day.

### Directories

| Directory Name    | Description                                                                   |
|-------------------|-------------------------------------------------------------------------------|
| `iam`             | Terraform module for IAM roles and polcies used by the lambda functions       |
| `lambda`          | Terraform module creating Lambda Functions for RDS backups/restorations.      |
| `vpc-endpoints`   | Terraform module for VPC Endpoints exposing resources to the private subnets. |