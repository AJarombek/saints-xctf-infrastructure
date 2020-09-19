### Overview

There are three modules.  The first is for creating a Lambda Function for database deployments.  The second creates 
IAM roles and policies for the Lambda functions.  The third creates an S3 bucket which holds the deployed database 
scripts.

### Directories

| Directory Name    | Description                                                                   |
|-------------------|-------------------------------------------------------------------------------|
| `iam`             | Terraform module for IAM roles and policies used by the lambda function.      |
| `lambda`          | Terraform module creating a Lambda Function for database deployments.         |
| `s3`              | Terraform module for an S3 bucket that holds database deployments.            |