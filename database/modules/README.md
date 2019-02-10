### Overview

There are two modules for creating a MySQL database environment.  The first creates the actual RDS instance.  The second 
handles database backups.  These two modules are located in `rds` and `s3`, respectively.

### Directories

| Directory Name    | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `rds`             | Terraform module for a MySQL RDS instance.                                  |
| `s3`              | Terraform module for an S3 bucket that holds database backups.              |