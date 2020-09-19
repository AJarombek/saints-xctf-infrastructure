### Overview

AWS infrastructure shared between the *DEV* and *PROD* environments.

```bash
# Create Infrastructure
terraform init -upgrade
terraform plan
terraform validate
terraform apply -auto-approve

# Destroy Infrastructure
terraform destroy -auto-approve
```

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `main.tf`           | Terraform module for infrastructure shared between the `DEV` and `PROD` lambda functions.    |

### Resources

1. [Terraform Import Existing Infrastructure](https://learn.hashicorp.com/terraform/state/import)
2. [IAM Role Resource Import](https://www.terraform.io/docs/providers/aws/r/iam_role.html#import)