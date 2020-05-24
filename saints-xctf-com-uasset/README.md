### Overview

S3 bucket containing assets uploaded by users on the SaintsXCTF website.  This bucket is used in the V2 application.  
Assets are accessible through the `uasset.saintsxctf.com` domain.

### Files

| Filename     | Description                                                                                      |
|--------------|--------------------------------------------------------------------------------------------------|
| `assets`     | Any non-user assets in this bucket.                                                              |
| `main.tf`    | Main Terraform script used to create and populate the S3 bucket.                                 |