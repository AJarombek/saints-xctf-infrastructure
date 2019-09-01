### Overview

Module for creating an AWS Lambda function.

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `main.tf`           | Main Terraform file that creates an AWS Lambda function.                                     |
| `role.json`         | IAM Role for the AWS Lambda function.                                                        |
| `var.tf`            | Input variables for the AWS Lambda function module.                                          |
| `zip-lambda.sh`     | Bash script which zips all the appropriate files for the AWS Lambda function.                |

### Resources

1) [IAM Policy Actions for Lambda in Private Subnet](https://github.com/serverless/serverless/issues/2780#issuecomment-312647780)
2) [Zip Files from Terraform](https://www.terraform.io/docs/providers/archive/d/archive_file.html)
3) [MySQL to S3 Example](https://github.com/crusepartnership/mysqldump-to-s3)
4) [Run AWS Lambda Function on Schedule](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/RunLambdaSchedule.html)