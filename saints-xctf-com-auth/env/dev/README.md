### Commands

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