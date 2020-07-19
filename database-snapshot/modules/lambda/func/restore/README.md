### Overview

Files specific to the restore AWS Lambda function source code.

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `lambda.py`         | AWS Lambda function source code.                                                             |
| `restore.sh`        | Bash script which is invoked by the Python function.  Calls the `mysql` CLI.                 |
| `mysql`             | Binary for the `mysql` CLI.                                                                  |