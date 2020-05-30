### Commands

```bash
# Create the infrastructure.
terraform init
terraform validate
terraform plan -detailed-exitcode -out=terraform-prod.tfplan
terraform apply -auto-approve terraform-prod.tfplan

# Destroy the infrastructure.
terraform plan -destroy
terraform destroy -auto-approve
```