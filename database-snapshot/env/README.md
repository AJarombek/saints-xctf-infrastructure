### Overview

There are two environments that need RDS backup AWS Lambda functions - *DEV* and *PROD*.  The code to configure *DEV* 
resides in `dev` and the code to configure *PROD* resides in `prod`.

### Directories

| Directory Name    | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `dev`             | Code to build a Lambda function for RDS backups in the *DEV* environment.   |
| `prod`            | Code to build a Lambda function for RDS backups in the *PROD* environment.  |