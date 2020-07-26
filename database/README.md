### Overview

These subdirectories contain all the Terraform scripts needed to create MySQL databases.  There is one MySQL database per
environment.  There are two environments, *DEV* for development purposes and *PROD* for users of the application.  The 
code to create a generic MySQL database exists in the `modules` directory.  The code to configure a MySQL database 
based on the environment resides in the `env` directory.  

Building the AWS infrastructure for MySQL with Terraform occurs in the `env` directory.  The Terraform scripts in `env` 
pass variables to the modules in `modules` to configure the database.

### Directories

| Directory Name    | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `env`             | Code to build a MySQL database for *DEV* and *PROD* environments.           |
| `modules`         | Modules for building MySQL databases.                                       |