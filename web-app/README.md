### Overview

These subdirectories contain all the Terraform scripts to help create the web application.  There is one web app per
environment.  There are two environments, *DEV* for development purposes and *PROD* for users of the application.  The 
code to create an S3 bucket holding application code exists in the `modules` directory.  The code to populate the S3  
bucket based on the environment resides in the `env` directory.  

The S3 infrastructure holding web app code is built in the `env` directory.  The Terraform scripts in  
`env` pass variables to the modules in `modules` to configure the S3 bucket.

### Directories

| Directory Name    | Description                                                                     |
|-------------------|---------------------------------------------------------------------------------|
| `env`             | Code to assist building the web application for *DEV* and *PROD* environments.  |
| `modules`         | Modules for building the web applications S3 bucket.                            |