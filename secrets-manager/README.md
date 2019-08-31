### Overview

Infrastructure for configuring secret credentials with AWS Secrets Manager.  Currently used for database credentials.  

Building the AWS infrastructure for Secrets Manager with Terraform occurs in the `env` directory.  The Terraform 
scripts in `env` pass variables to the modules in `modules` to configure the credentials.

### Directories

| Directory Name    | Description                                                                   |
|-------------------|-------------------------------------------------------------------------------|
| `env`             | Code to configure AWS Secrets Manager for *DEV* and *PROD* environments.      |
| `modules`         | Modules for configuring AWS Secrets Manager.                                  |