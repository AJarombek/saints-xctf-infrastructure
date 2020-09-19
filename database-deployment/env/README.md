### Overview

There are separate database deployment AWS Lambda functions for *DEV* and *PROD* environments.  The S3 bucket and IAM 
roles/policies are shared between the two environments.

### Directories

| Directory Name    | Description                                                                          |
|-------------------|--------------------------------------------------------------------------------------|
| `all`             | Infrastructure shared between the *DEV* and *PROD* environments.                     |
| `dev`             | Code to build a Lambda function for database deployments in the *DEV* environment.   |
| `prod`            | Code to build a Lambda function for database deployments in the *PROD* environment.  |