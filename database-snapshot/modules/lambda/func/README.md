### Overview

Files specific to the AWS Lambda function source code.

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `lambda.py`         | AWS Lambda function source code.                                                             |
| `backup.sh`         | Bash script which is invoked by the Python function.  Calls the `mysqldump` CLI.             |
| `mysqldump`         | Binary for the `mysqldump` CLI.                                                              |