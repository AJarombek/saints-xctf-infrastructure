# saints-xctf-infrastructure

### Overview

This repository holds application specific infrastructure for the [saintsxctf.com](https://www.saintsxctf.com/) website.  The 
VPCs for SaintsXCTF.com are configured in the [global-aws-infrastructure](https://github.com/AJarombek/global-aws-infrastructure) 
repository.

### Commands

**One Time Bazel Setup (MacOS)**

```bash
brew tap bazelbuild/tap
brew install bazelbuild/tap/bazel

# Confirm the installation was successful.
bazel --version
```

### Infrastructure Diagram

![AWS Model](aws-model.png)

*Last Updated: Feb 10th, 2019*

### Directories

| Directory Name            | Description                                                                         |
|---------------------------|-------------------------------------------------------------------------------------|
| `acm`                     | HTTPS Certificates for the application load balancer.                               |
| `bastion`                 | Bastion host for connecting to resources in the private subnets.                    |
| `database`                | Infrastructure for the SaintsXCTF MySQL database.                                   |
| `database-backup`         | S3 buckets for storing RDS database backups.                                        |
| `database-deployment`     | Lambda function for deploying scripts to RDS databases.                             |
| `database-snapshot`       | Lambda functions for creating backups and restoring RDS databases.                  |
| `iam`                     | IAM policies used in the SaintsXCTF VPC.                                            |
| `route53`                 | Configures the DNS records for the application.                                     |
| `saints-xctf-com`         | Kubernetes configuration for the application front-end (V2).                        |
| `saints-xctf-com-api`     | Kubernetes configuration for the application API (V2).                              |
| `saints-xctf-com-asset`   | S3 bucket containing assets used for the SaintsXCTF application (V2).               |
| `saints-xctf-com-auth`    | Authentication API and Lambda functions (V2).                                       |
| `saints-xctf-com-fn`      | API of Lambda functions used for different purposes including sending emails (V2).  |
| `saints-xctf-com-uasset`  | S3 bucket containing application users assets (V2).                                 |
| `secrets-manager`         | Secrets for the SaintsXCTF application and infrastructure.                          |
| `web-server`              | Infrastructure for the SaintsXCTF Web Server.                                       |
| `web-app`                 | Setup for the websites application code.                                            |
| `test`                    | Test code for the AWS infrastructure.                                               |

### Resources

1. [Bazel Installation](https://docs.bazel.build/versions/3.2.0/install-os-x.html)