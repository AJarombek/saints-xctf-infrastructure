### Overview

MySQL database configuration for the *PROD* environment.  In order for this module to work, the databases
`username` and `password` must be passed in via the command line:

```bash
terraform apply -var 'username=XXX' -var 'password=XXX'
```

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `main.tf`           | Terraform module for the `PROD` database.                                                    |
| `var.tf`            | Variables passed in via the command line.                                                    |