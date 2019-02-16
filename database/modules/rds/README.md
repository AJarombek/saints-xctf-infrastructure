### Overview

Module for creating RDS infrastructure.  Currently just creates a MySQL database for SaintsXCTF in a given environment.

### Files

| Filename          | Description                                                                                      |
|-------------------|--------------------------------------------------------------------------------------------------|
| `main.tf`         | Main Terraform script for the RDS module.  Creates a MySQL database in a given environment.      |
| `var.tf`          | Variables to pass into the main Terraform script.                                                |