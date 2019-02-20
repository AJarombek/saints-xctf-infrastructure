### Overview

Module for creating an S3 bucket for the SaintsXCTF application.  The module is passed variables which determine the 
environment of the S3 bucket and which files are placed in the S3 bucket.

### Files

| Filename          | Description                                                                                  |
|-------------------|----------------------------------------------------------------------------------------------|
| `policies/`       | Bucket policies written in JSON.                                                             |
| `main.tf`         | Main Terraform file for the S3 module.                                                       |
| `var.tf`          | Variables to pass into the main Terraform file.                                              |