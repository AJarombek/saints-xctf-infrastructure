### Overview

These subdirectories contain all the Terraform scripts needed to create web servers.  There is one web server per
environment.  There are two environments, *DEV* for development purposes and *PROD* for users of the application.  The 
code to create a generic web server exists in the `modules` directory.  The code to configure a web server 
based on the environment resides in the `env` directory.  

Building the AWS infrastructure for a web server with Terraform occurs in the `env` directory.  The Terraform scripts in  
`env` pass variables to the modules in `modules` to configure the web server.

### Dependencies

The web servers are reliant on three pieces of infrastructure.  The first is a MySQL database for the given environment.  
The second is ACM certificates for HTTPS requests.  The third is an S3 bucket holding credentials for the given 
environment.  These dependencies are found in the `database`, `acm`, and `web-app` directories, respectively.

Once the web server is created, the route53 module must run to set up the domain name with an HTTPS certificate.  
Route53 is found in the `route53` module.

### Directories

| Directory Name    | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `env`             | Code to build a web server for *DEV* and *PROD* environments.               |
| `modules`         | Modules for building web servers.                                           |