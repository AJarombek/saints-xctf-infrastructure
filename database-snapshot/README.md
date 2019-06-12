### Overview

Infrastructure for building an AWS Lambda function which creates a backup of an RDS MySQL database.  

Building the AWS infrastructure for the Lambda function with Terraform occurs in the `env` directory.  The Terraform 
scripts in `env` pass variables to the modules in `modules` to configure the lambda function.

### Directories

| Directory Name    | Description                                                                   |
|-------------------|-------------------------------------------------------------------------------|
| `env`             | Code to build a RDS backup lambda function for *DEV* and *PROD* environments. |
| `modules`         | Modules for building a RDS backup lambda function.                            |