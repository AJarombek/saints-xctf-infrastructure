### Overview

Launch configuration and auto scaling for the web server in the *DEV* environment.  Run the following commands to 
build the launch config:

```
terraform init
terraform plan
terraform apply
```

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `main.tf`           | Terraform module for the `DEV` web server.                                                   |