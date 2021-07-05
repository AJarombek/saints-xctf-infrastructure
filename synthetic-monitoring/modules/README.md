### Overview

There are three modules for configuring AWS Synthetic Monitoring.  `canaries` creates canary functions which perform 
end to end tests.  `iam` creates IAM roles/policies for the canary functions, and `s3` creates an S3 bucket that holds 
the results on the canary functions.

### Directories

| Directory Name    | Description                                                                        |
|-------------------|------------------------------------------------------------------------------------|
| `canaries`        | Terraform module for CloudWatch Synthetic Monitoring Canary functions/e2e tests.   |
| `iam`             | Terraform module for IAM roles/policies used by CloudWatch Synthetic Monitoring.   |
| `s3`              | Terraform module for an S3 bucket used by CloudWatch Synthetic Monitoring.         |