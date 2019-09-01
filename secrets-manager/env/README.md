### Overview

There are two environments that need RDS database secrets - *DEV* and *PROD*.  The code to configure *DEV* 
resides in `dev` and the code to configure *PROD* resides in `prod`.

### Directories

| Directory Name    | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `dev`             | Code to configure secret credentials for RDS in the *DEV* environment.      |
| `prod`            | Code to configure secret credentials for RDS in the *PROD* environment.     |

### Resources

1) [Terraform CLI Variable of Type Map](https://learn.hashicorp.com/terraform/getting-started/variables.html#assigning-maps)