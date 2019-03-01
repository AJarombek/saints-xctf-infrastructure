### Overview

Creates a DNS zone and holds the DNS records for the SaintsXCTF application.  There are two main DNS entries - one for 
the development web server `dev.saintsxctf.com` and a second for the production web server `saintsxctf.com`.  The 
`route53` module also configures HTTPS certificates for the web servers using 
[Certbot](https://certbot.eff.org/lets-encrypt/ubuntuxenial-apache.html).

### Directories

| Directory Name    | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `env`             | Code to build DNS records for *DEV*, *PROD*, and global environments.       |
| `modules`         | Modules for building DNS records.                                           |