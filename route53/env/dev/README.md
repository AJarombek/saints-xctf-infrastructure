### Overview

Configures DNS records for the `dev.saintsxctf.com` subdomain.  This module is applied **after** the `web-server` module 
because it also sets up an HTTPS certificate on each EC2 instance in the websites auto scaling group.

### Files

| Filename             | Description                                                                                                 |
|----------------------|-------------------------------------------------------------------------------------------------------------|
| `main.tf`            | Terraform script for creating DNS records in Route53 along with an HTTPS certificate for the web server.    |