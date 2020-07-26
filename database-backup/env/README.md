### Overview

There are two environments that need MySQL database backup S3 buckets - *DEV* and *PROD*.  The code to configure *DEV* 
resides in `dev` and the code to configure *PROD* resides in `prod`.

### Directories

| Directory Name    | Description                                                                                  |
|-------------------|----------------------------------------------------------------------------------------------|
| `dev`             | Code to build a MySQL database backup S3 bucket for the *DEV* environment.                   |
| `prod`            | Code to build a MySQL database backup S3 bucket for the *PROD* environment.                  |