### Overview

AWS Lambda function for RDS backups in the *DEV* environment.  From this directory, run the following commands to build 
the infrastructure:

```bash
# Create Infrastructure
terraform init -upgrade
terraform plan
terraform validate
terraform apply -auto-approve

# Destroy Infrastructure
terraform destroy -auto-approve
```

> NOTE: The Lambda Function can also be created via a Jenkins Job.

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `main.tf`           | Terraform module for the `DEV` lambda function.                                              |