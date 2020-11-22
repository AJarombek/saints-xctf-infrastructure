### Overview

Terraform modules for creating an AWS API Gateway and AWS Lambda infrastructure for `fn.saintsxctf.com`.

### Directories

| Directory Name    | Description                                                                                                     |
|-------------------|-----------------------------------------------------------------------------------------------------------------|
| `api-gateway`     | Terraform module that creates an API Gateway REST API for `fn.saintsxctf.com`.                                  |
| `email-lambda`    | Terraform module which creates AWS Lambda functions for sending emails.                                         |
| `uasset-lambda`   | Terraform module which creates AWS Lambda functions that interacts with the `uasset.saintsxctf.com` S3 bucket.  |