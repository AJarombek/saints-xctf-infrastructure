### Overview

Contains files that create a web server.  There are two main steps to create the web server.  The first step is to
build an AMI with Packer.  This is done in the `ami` directory.  The second step is to execute the Terraform scripts, 
creating a launch configuration and auto-scaling group for the web server.

### Files

| Filename                 | Description                                                                                      |
|--------------------------|--------------------------------------------------------------------------------------------------|
| `ami/`                   | Creates the AMI that the web server will run on.                                                 |
| `main.tf`                | Main Terraform script for the launch configuration module.                                       |
| `var.tf`                 | Variables to pass into the main Terraform script.                                                |
| `saints-xctf-startup.sh` | Bash script that runs as soon as the web server EC2 instance boots.                              |
| `saintsxctf-key-gen.sh`  | Bash script executed before the terraform scripts run.  Creates a private key for EC2 debugging. |