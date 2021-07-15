# saints-xctf-infrastructure

![Maintained Label](https://img.shields.io/badge/Maintained-Yes-brightgreen?style=for-the-badge)

### Overview

This repository holds application specific infrastructure for the [saintsxctf.com](https://www.saintsxctf.com/) website.  The 
VPCs for SaintsXCTF.com are configured in the [global-aws-infrastructure](https://github.com/AJarombek/global-aws-infrastructure) 
repository.

### SaintsXCTF Deployment Process

+ Run SaintsXCTF Database Deployment Scripts

+ Create Docker Images for SaintsXCTF API (Base & Nginx).  Bump up Image Versions.

+ Create Docker Images for SaintsXCTF Web (Base & Nginx).  Bump up Image Versions.

+ Build SaintsXCTF Auth API [If Necessary]

+ Build SaintsXCTF Function API [If Necessary]

+ Build SaintsXCTF Ingress Kubernetes Infrastructure [If Necessary]

+ Build SaintsXCTF API Kubernetes Infrastructure.  Bump Up Deployment Versions to Match Docker Images.

+ Build SaintsXCTF Web Kubernetes Infrastructure.  Bump Up Deployment Versions to Match Docker Images.

### Integration

There are multiple Jenkins jobs for this infrastructure.  They are all located in the SaintsXCTF
[`infrastructure`](http://jenkins.jarombek.io/job/saints-xctf/job/infrastructure/) folder:

[![Jenkins](https://img.shields.io/badge/Jenkins-%20saints--xctf--infrastructure--test--prod-blue?style=for-the-badge)](https://jenkins.jarombek.io/job/saints-xctf/job/infrastructure/job/saints-xctf-infrastructure-test-prod/)
> Runs tests on the production environment AWS infrastructure created with Terraform.

[![Jenkins](https://img.shields.io/badge/Jenkins-%20saints--xctf--infrastructure--test--dev-blue?style=for-the-badge)](https://jenkins.jarombek.io/job/saints-xctf/job/infrastructure/job/saints-xctf-infrastructure-test-dev/)
> Runs tests on the development environment AWS infrastructure created with Terraform.

### Commands

**One Time Bazel Setup (MacOS)**

```bash
brew tap bazelbuild/tap
brew install bazelbuild/tap/bazel

# Confirm the installation was successful.
bazel --version
```

### Directories

| Directory Name            | Description                                                                         |
|---------------------------|-------------------------------------------------------------------------------------|
| `acm`                     | HTTPS Certificates for the application load balancer.                               |
| `bastion`                 | Bastion host for connecting to resources in the private subnets.                    |
| `database`                | Infrastructure for the SaintsXCTF MySQL database.                                   |
| `database-backup`         | S3 buckets for storing RDS database backups.                                        |
| `database-client`         | MySQL database client for access to the RDS database from a web GUI.                |
| `database-deployment`     | Lambda function for deploying scripts to RDS databases.                             |
| `database-snapshot`       | Lambda functions for creating backups and restoring RDS databases.                  |
| `iam`                     | IAM policies used in the SaintsXCTF VPC.                                            |
| `route53`                 | Configures the DNS records for the application.                                     |
| `saints-xctf-com`         | Kubernetes configuration for the application front-end.                             |
| `saints-xctf-com-api`     | Kubernetes configuration for the application API.                                   |
| `saints-xctf-com-asset`   | S3 bucket containing assets used for the SaintsXCTF application .                   |
| `saints-xctf-com-auth`    | Authentication API and Lambda functions.                                            |
| `saints-xctf-com-fn`      | API of Lambda functions used for different purposes including sending emails.       |
| `saints-xctf-com-uasset`  | S3 bucket containing application users assets.                                      |
| `secrets-manager`         | Secrets for the SaintsXCTF application and infrastructure.                          |
| `synthetic-monitoring`    | CloudWatch Synthetic Monitoring for end to end testing.                             |
| `test`                    | Python AWS infrastructure test suite.                                               |
| `test-k8s`                | Go Kubernetes infrastructure test suite.                                            |

### Versions

**[v2.0.1](https://github.com/AJarombek/saints-xctf-infrastructure/tree/v2.0.1) - Synthetic Monitoring Canaries Release**

> Release Date: July 14th, 2021

This release added Canary functions, which provide automated tests for the SaintsXCTF website.  These functions test 
critical paths of the application on a schedule, and notify me if any errors are detected.

**[v2.0.0](https://github.com/AJarombek/saints-xctf-infrastructure/tree/v2.0.0) - Kubernetes/Serverless V2 Release**

> Release Date: May 30th, 2021

The SaintsXCTF website is now using its second version.  Unused infrastructure modules were removed.  The largest 
changes in this release include:

* SaintsXCTF Ingress object & corresponding load balancer
* SaintsXCTF Web Kubernetes Deployment
* SaintsXCTF API Kubernetes Deployment
* `auth.saintsxctf.com` API Gateway & Lambda Functions
* `fn.saintsxctf.com` API Gateway & Lambda Functions
* Asset and User Asset S3 Buckets
* Database phpMyAdmin Client on Kubernetes

**[v1.0.0](https://github.com/AJarombek/saints-xctf-infrastructure/tree/v1.0.0) - First Release**

> Release Date: February 13th, 2021

First tag for the SaintsXCTF infrastructure repository.  Includes new infrastructure for version 2 of the application 
and old infrastructure for the original website I made in college (which was lift and shifted to AWS from Linode in 
2019).

### Resources

1. [Bazel Installation](https://docs.bazel.build/versions/3.2.0/install-os-x.html)