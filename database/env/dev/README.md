### Overview

MySQL and database backup configuration for the *DEV* environment.  In order for this module to work, the databases
`username` and `password` must be passed in via the command line:

```
terraform apply -var 'username=XXX' -var 'password=XXX'
```

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `main.tf`           | Terraform module for the `DEV` database.                                                     |
| `var.tf`            | Variables passed in via the command line.                                                    |
| `test.sh`           | Testing the connection to MySQL from different machines.                                     |