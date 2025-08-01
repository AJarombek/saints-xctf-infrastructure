### Overview

Infrastructure for a database client that can connect to the development and production RDS databases.

[db.saintsxctf.com](https://db.saintsxctf.com) can take 15-30 minutes for DNS changes to propagate.

### Commands

**SQL Queries**

```sql
-- Determine the version of MySQL the server is using
SELECT version();
```

### Files

| Filename             | Description                                                                                  |
|----------------------|----------------------------------------------------------------------------------------------|
| `k8s-config`         | Kubernetes YAML documents for objects built with Terraform.  These are for reference only.   |
| `main.tf`            | Main Terraform script of the database client module.                                         |
| `var.tf`             | Variables used in the Terraform database client module.                                      |