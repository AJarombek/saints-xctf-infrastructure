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

There are multiple Jenkins jobs for this infrastructure, all located in the SaintsXCTF
[`infrastructure`](http://jenkins.jarombek.io/job/saints-xctf/job/infrastructure/) folder.

### Commands

**Run GitHub Actions Locally**

```bash
act -W '.github/workflows/aws_tests.yml' --detect-event
```

### Directories

| Directory Name           | Description                                                                   |
|--------------------------|-------------------------------------------------------------------------------|
| `.github`                | GitHub Actions for CI/CD pipelines.                                           |
| `acm`                    | HTTPS Certificates for the application load balancer.                         |
| `bastion`                | Bastion host for connecting to resources in the private subnets.              |
| `database`               | Infrastructure for the SaintsXCTF MySQL database.                             |
| `database-backup`        | S3 buckets for storing RDS database backups.                                  |
| `database-client`        | MySQL database client for access to the RDS database from a web GUI.          |
| `database-deployment`    | Lambda function for deploying scripts to RDS databases.                       |
| `database-snapshot`      | Lambda functions for creating backups and restoring RDS databases.            |
| `iam`                    | IAM policies used in the SaintsXCTF VPC.                                      |
| `route53`                | Configures the DNS records for the application.                               |
| `saints-xctf-com`        | Kubernetes configuration for the application front-end.                       |
| `saints-xctf-com-api`    | Kubernetes configuration for the application API.                             |
| `saints-xctf-com-asset`  | S3 bucket containing assets used for the SaintsXCTF application .             |
| `saints-xctf-com-auth`   | Authentication API and Lambda functions.                                      |
| `saints-xctf-com-fn`     | API of Lambda functions used for different purposes including sending emails. |
| `saints-xctf-com-uasset` | S3 bucket containing application users assets.                                |
| `secrets-manager`        | Secrets for the SaintsXCTF application and infrastructure.                    |
| `synthetic-monitoring`   | CloudWatch Synthetic Monitoring for end to end testing.                       |
| `test`                   | Python AWS infrastructure test suite.                                         |
| `test-k8s`               | Go Kubernetes infrastructure test suite.                                      |

### Versions

**[v2.0.5](https://github.com/AJarombek/saints-xctf-infrastructure/tree/v2.0.5) - ACM Updates**

> Release Date: January 28th, 2024

+ Update ACM certificates for `saintsxctf.com` and `*.saintsxctf.com`.
+ Remove Unused ACM certificates.
+ Remove CloudFront Distributions for `www.` subdomains.

**[v2.0.4](https://github.com/AJarombek/saints-xctf-infrastructure/tree/v2.0.4) - Kubernetes Tests Upgraded**

> Release Date: June 4th, 2023

+ Kubernetes Ingress Tests Fixed
+ Kubernetes Tests Upgraded to Go 1.20

**[v2.0.3](https://github.com/AJarombek/saints-xctf-infrastructure/tree/v2.0.3) - EKS V2 Cluster**

> Release Date: April 3rd, 2023

Integrate the API and website with the V2 EKS cluster.

**[v2.0.2](https://github.com/AJarombek/saints-xctf-infrastructure/tree/v2.0.2) - GitHub Actions**

> Release Date: February 26th, 2023

Integrate Terraform formatting, AWS tests, and Kubernetes tests with GitHub Actions CI/CD.

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