### Overview

Infrastructure for the SaintsXCTF Auth API (`auth.saintsxctf.com`) shared between both *DEV* and *PROD* environments.  
Creates VPC endpoints needed by the functions.

### Commands

**Commands for Building the Infrastructure Locally**

```bash
# Create the infrastructure.
terraform init
terraform validate
terraform plan -detailed-exitcode -out=terraform-dev.tfplan
terraform apply -auto-approve terraform-dev.tfplan

# Destroy the infrastructure.
terraform plan -destroy
terraform destroy -auto-approve
```

### Files

| Filename             | Description                                                                              |
|----------------------|------------------------------------------------------------------------------------------|
| `main.tf`            | The Terraform script shared infrastructure for `auth.saintsxctf.com`.                    |