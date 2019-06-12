### Overview

AWS Lambda function for RDS backups in the *PROD* environment.  From this directory, run the following commands to build 
the infrastructure:

```
terraform init -upgrade
terraform plan
terraform validate
terraform apply -auto-approve
```

> NOTE: The Lambda Function should always be created via a Jenkins Job.  The Jenkins Job properly packages the source 
code and runs the Terraform configuration.

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `main.tf`           | Terraform module for the `PROD` lambda function.                                             |