# saints-xctf-infrastructure

### Overview

This repository holds application specific infrastructure for the [saintsxctf.com](https://www.saintsxctf.com/) website.  The 
VPCs for SaintsXCTF.com are configured in the [global-aws-infrastructure](https://github.com/AJarombek/global-aws-infrastructure) 
repository.

### Infrastructure Diagram

![AWS Model](aws-model.png)

*Last Updated: Feb 10th, 2019*

### Directories

| Directory Name    | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `database`        | Infrastructure for the SaintsXCTF MySQL database.                           |
| `web-server`      | Infrastructure for the SaintsXCTF Web Server.                               |
| `web-app`         | Setup for the websites application code.                                    |
| `acm`             | HTTPS Certificates for the application load balancer.                       |
| `route53`         | Configures the DNS records for the application.                             |
| `s3-asset`        | S3 bucket containing assets used for the SaintsXCTF application (V2).       |
| `s3-uasset`       | S3 bucket containing application users assets (V2).                         |
| `saints-xctf-v2`  | ECS configuration for the application front-end and api (V2).               |
| `iam`             | IAM policies used in the SaintsXCTF VPC.                                    |
| `bastion`         | Bastion host for connecting to resources in the private subnets.            |
| `test`            | Test code for the AWS infrastructure.                                       |