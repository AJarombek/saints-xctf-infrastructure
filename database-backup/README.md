### Overview

These subdirectories contain all the Terraform scripts needed to create an S3 bucket that holds MySQL databases backups.

### Directories

| Directory Name    | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `env`             | Code to build a MySQL database for *DEV* and *PROD* environments.           |
| `modules`         | Modules for building an S3 bucket which contains database backups.          |

### Resources

1. [Remove From Terraform Managed State](https://www.terraform.io/docs/commands/state/rm.html)