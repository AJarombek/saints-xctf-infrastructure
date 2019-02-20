### Overview

There is currently one module for creating a web server - `launch-config`.  It creates a new launch configuration and 
auto scaling group for hosting the SaintsXCTF web server.  It also holds the code to build an AMI for the web server.

### Directories

| Directory Name    | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `launch-config`   | Terraform module for a web servers launch configuration.                    |