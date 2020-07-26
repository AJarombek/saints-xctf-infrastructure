### Overview

Contains files that create backups of the RDS MySQL database.  The backups are placed in S3.

### Files

| Filename            | Description                                                                                    |
|---------------------|------------------------------------------------------------------------------------------------|
| `policies/`         | IAM policies for the S3 bucket.                                                                |
| `main.tf`           | Main Terraform script for the S3 database backup module.                                       |
| `var.tf`            | Variables to pass into the main Terraform script.                                              |
| `initial_backup.sh` | Store an initial MySQL backup on S3.  Called after the S3 bucket is generated.                 |