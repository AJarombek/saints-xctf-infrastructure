### Overview

Terraform module for AWS Lambda functions related to manipulating objects in the `uasset.saintsxctf.com` S3 bucket.  
These functions are called from the `fn.saintsxctf.com` API Gateway REST API under the `/uasset` route.

### Files

| Filename                        | Description                                                                                  |
|---------------------------------|----------------------------------------------------------------------------------------------|
| `main.tf`                       | Main Terraform script of the AWS Lambda email functions module.                              |
| `var.tf`                        | Variables used in the Terraform AWS Lambda email functions module.                           |
| `outputs.tf`                    | Output variables from the Terraform AWS Lambda email functions module.                       |
| `lambda-policy.json`            | IAM policy for the AWS Lambda functions.                                                     |
| `lambda-role.json`              | IAM assume role policy for the AWS Lambda functions.                                         |