### Overview

There are three modules.  The first is for creating Lambda Functions for RDS backups & restorations.  The second creates 
IAM roles and policies for the Lambda functions.  The third creates VPC endpoints to access resources from private 
subnets without a NAT gateway.

### Directories

| Directory Name    | Description                                                                   |
|-------------------|-------------------------------------------------------------------------------|
| `iam`             | Terraform module for IAM roles and polcies used by the lambda functions       |
| `lambda`          | Terraform module creating Lambda Functions for RDS backups/restorations.      |
| `vpc-endpoints`   | Terraform module for VPC Endpoints exposing resources to the private subnets. |