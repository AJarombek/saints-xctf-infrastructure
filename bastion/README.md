### Overview

Infrastructure for a Bastion host, which connects to the private resources in the VPC.  A Bastion host is needed because 
resources inside private VPCs are not publicly available outside the VPC.

### Commands

#### Create the Infrastructure

```bash
terraform init
terraform validate

sudo -s
terraform plan
terraform apply -auto-approve
```

#### Connect to MySQL on the Bastion host

**Bash commands to run from a local machine**

```bash
# SSH into the Bastion host
ssh -i ~/bastion-key.pem -o IdentitiesOnly=yes ec2-user@ec2-xxx-xxx-xxx-xxx.compute-1.amazonaws.com
```

**Bash commands to run on the Bastion host**

```bash
export AWS_DEFAULT_REGION=us-east-1

# Get the Dev host.
DEV_HOST=$(
    aws rds describe-db-instances \
        --db-instance-identifier saints-xctf-mysql-database-dev \
        --query "DBInstances[0].Endpoint.Address" \
        --output text
)

# Connect to the development database.
mysql -h ${DEV_HOST} -u saintsxctfdev -p

# Get the Production host.
PROD_HOST=$(
    aws rds describe-db-instances \
        --db-instance-identifier saints-xctf-mysql-database-prod \
        --query "DBInstances[0].Endpoint.Address" \
        --output text
)

# Connect to the production database.
mysql -h ${PROD_HOST} -u saintsxctfprod -p
```

#### SSH Tunnel to MySQL on the local machine

*Work in progress*

### Files

| Filename                | Description                                                                                      |
|-------------------------|--------------------------------------------------------------------------------------------------|
| `main.tf`               | Terraform script for creating a Bastion host in the SaintsXCTF public VPC.                       |
| `bastion-key-setup.sh`  | Before the terraform resources are created, create public/private keys for Bastion connections.  |
| `bastion-setup.sh`      | Commands to run on the Bastion VM when its created.                                              |
| `use-cases.sh`          | Different Bash commands commonly used on the Bastion host.                                       |