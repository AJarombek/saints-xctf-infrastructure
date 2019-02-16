### Overview

These subdirectories contain all the Terraform scripts needed to create web servers.  There is one web server per
environment.  There are two environments, *DEV* for development purposes and *PROD* for users of the application.  The 
code to create a generic web server exists in the `modules` directory.  The code to configure a web server 
based on the environment resides in the `env` directory.  

Building the AWS infrastructure for a web server with Terraform occurs in the `env` directory.  The Terraform scripts in  
`env` pass variables to the modules in `modules` to configure the web server.

### Directories

| Directory Name    | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `env`             | Code to build a web server for *DEV* and *PROD* environments.               |
| `modules`         | Modules for building web servers.                                           |