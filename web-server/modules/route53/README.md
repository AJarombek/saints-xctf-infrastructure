### Overview

Holds the DNS records for the SaintsXCTF application.  There are two main DNS entries - one for the development web 
server `dev.saintsxctf.com` and a second for the production web server `saintsxctf.com`.

### Files

| Filename             | Description                                                                                  |
|----------------------|----------------------------------------------------------------------------------------------|
| `main.tf`            | The Terraform script for creating DNS records in Route53.                                    |
| `var.tf`             | Variables used by the main Terraform script.                                                 |
| `configure-https.sh` | Bash script which configures HTTPS for a domain after the corresponding A record is created. |