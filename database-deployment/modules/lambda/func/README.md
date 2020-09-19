### Overview

Files specific to the database deployment AWS Lambda function source code.

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `lambda.py`         | AWS Lambda function source code.                                                             |
| `deploy.sh`         | Bash script which is invoked by the Python function.  Calls the `mysql` CLI.                 |
| `mysql`             | Binary for the `mysql` CLI.                                                                  |