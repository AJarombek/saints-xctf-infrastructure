### Overview

IAM infrastructure for GitHub Actions to assume a Terraform deployment role with OIDC.

### Resources

- `aws_iam_role.github_terraform`: OIDC-assumable role `saints-xctf-github-terraform`
- `aws_iam_policy.terraform_backend`: Access to Terraform S3 state and DynamoDB locks
- `aws_iam_policy.terraform_services`: Service permissions for infrastructure modules run in CI

### Usage

```bash
terraform init
terraform plan
terraform apply
```

