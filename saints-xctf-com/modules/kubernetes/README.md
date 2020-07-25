### Overview

Infrastructure for an ECR repository used by the SaintsXCTF web application in the *DEV* and *PROD* environments.

### Files

| Filename             | Description                                                                                  |
|----------------------|----------------------------------------------------------------------------------------------|
| `k8s-config`         | Kubernetes YAML documents for objects built with Terraform.  These are for reference only.   |
| `main.tf`            | Main Terraform script of the Kubernetes module.                                              |
| `var.tf`             | Variables used in the Terraform Kubernetes module.                                           |