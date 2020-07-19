### Overview

Infrastructure for building two AWS Lambda functions.  The first creates a backup of an RDS MySQL database.  The second
takes a backup `.sql` file and restores a database to the state defined in that file.

Building the AWS infrastructure for the Lambda functions with Terraform occurs in the `env` directory.  The Terraform 
scripts in `env` pass variables to the modules in `modules` to configure the lambda functions.

### Directories

| Directory Name    | Description                                                                          |
|-------------------|--------------------------------------------------------------------------------------|
| `env`             | Code to build RDS backup/restore lambda functions for *DEV* and *PROD* environments. |
| `modules`         | Modules for building RDS backup/restore lambda functions.                            |