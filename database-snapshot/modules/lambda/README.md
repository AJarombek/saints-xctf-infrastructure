### Overview

Module for creating an AWS Lambda function.

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `main.tf`           | Main Terraform file that creates an AWS Lambda function.                                     |
| `role.json`         | IAM Role for the AWS Lambda function.                                                        |
| `var.tf`            | Input variables for the AWS Lambda function module.                                          |
| `zip-lambda.sh`     | Bash script which zips all the appropriate files for the AWS Lambda function.                |