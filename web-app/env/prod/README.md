### Overview

Module for creating an S3 bucket for the SaintsXCTF application in the *PROD* environment.  This bucket must exist for 
the web application to run properly.

### Files

| Filename          | Description                                                                                  |
|-------------------|----------------------------------------------------------------------------------------------|
| `contents/`       | Contains files to place on S3. *NOT CHECKED IN TO GIT*                                       |
| `main.tf`         | Builds the S3 bucket for the web application in *PROD*.                                      |