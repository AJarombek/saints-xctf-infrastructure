### Overview

Secret credentials for RDS instances in the *PROD* environment.  From this directory, run the following commands to build 
the infrastructure.  Replace `XXX` with the database password.

```bash
# Create Infrastructure
terraform init -upgrade
terraform plan
terraform validate
terraform apply -auto-approve -var 'rds_secrets={ username = "saintsxctfprod", password = "XXX" }'

# Destroy Infrastructure
terraform destroy -auto-approve
```

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `main.tf`           | Terraform module for the `PROD` secret credentials.                                          |
| `var.tf`            | Input variables for the `PROD` database secrets.                                             |