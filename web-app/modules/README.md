### Overview

There is currently one module for the web application - `s3`.  It creates an S3 bucket the holds web application files  
for SaintsXCTF.  Most application files live on GitHub in the [saints-xctf](https://github.com/AJarombek/saints-xctf) 
repository, however there are some files the hold secret material.  These files are handled by the `s3` module.

### Directories

| Directory Name    | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `s3`              | Terraform module for an S3 bucket holding web application code.             |