# Database Client ECS Infrastructure

This directory contains Terraform infrastructure for running PhpMyAdmin as an ECS service for adhoc MySQL database administration.

## Overview

This infrastructure migrates the previous Kubernetes-based database client (located in `../database-client/`) to AWS ECS Fargate. The service is designed for adhoc access only and should not be kept running continuously.

## Architecture

- **ECS Cluster**: `saints-xctf-database-client`
- **ECS Service**: Running PhpMyAdmin container
- **Load Balancer**: Application Load Balancer (ALB) with HTTPS support
- **DNS**: `db.saintsxctf.com`
- **Container**: `phpmyadmin/phpmyadmin:latest`
- **Resources**: 256 CPU, 512 MB memory (minimal tier for adhoc use)

## Security

- HTTPS/TLS required (HTTP redirects to HTTPS)
- ALB security group restricts access via configurable CIDR block
- Access control via `db_client_access_cidr` variable (defaults to open for local testing)

## Usage

### Deploy

```bash
cd database-client-ecs
terraform init
terraform plan
terraform apply
```

### Restrict Access

To restrict access to specific IP addresses/ranges:

```bash
terraform apply -var="db_client_access_cidr=203.0.113.0/24"
```

### Access the Service

Once deployed, navigate to: `https://db.saintsxctf.com`

The PhpMyAdmin interface will be available with `PMA_ARBITRARY=1` enabled, allowing connection to any MySQL server.

### Destroy

When finished with database administration:

```bash
terraform destroy
```

## Configuration

Environment variables for PhpMyAdmin:
- `PMA_ARBITRARY=1` - Allows connection to any MySQL server without predefined hostnames

See [PhpMyAdmin documentation](https://docs.phpmyadmin.net/en/latest/) for additional configuration options.

## Terraform State

State is stored in S3 bucket:
- Bucket: `andrew-jarombek-terraform-state`
- Key: `saints-xctf-infrastructure/database-client-ecs`
- Region: `us-east-1`

## Historical Context

Previously, database client access was managed via Kubernetes deployment. This ECS version provides:
- Simpler infrastructure for adhoc use cases
- No dependency on EKS cluster
- Easier to start/stop for cost management
- Consistent with other application deployments (UI/API)

The original Kubernetes configuration can be found in `../database-client/main.tf`

