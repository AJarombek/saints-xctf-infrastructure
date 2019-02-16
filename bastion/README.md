### Overview

Infrastructure for a Bastion host, which connects to the private resources in the VPC.  A Bastion host is needed because 
resources inside private VPCs are not publicly available outside the VPC.

### Files

| Filename                | Description                                                                                      |
|-------------------------|--------------------------------------------------------------------------------------------------|
| `main.tf`               | Terraform script for creating a Bastion host in the SaintsXCTF public VPC.                       |
| `bastion-key-setup.sh`  | Before the terraform resources are created, create public/private keys for Bastion connections.  |
| `bastion-setup.sh`      | Commands to run on the Bastion VM when its created.                                              |
| `use-cases.sh`          | Different Bash commands commonly used on the Bastion host.                                       |