### Overview

Files specific to the backup AWS Lambda function source code.

### Files

| Filename            | Description                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------|
| `lambda.py`         | AWS Lambda function source code.                                                             |
| `backup.sh`         | Bash script which is invoked by the Python function.  Calls the `mysqldump` CLI.             |
| `mysqldump`         | Binary for the `mysqldump` CLI.                                                              |

### Resources

1) [S3 Object Upload via VPC Endpoint](https://stackoverflow.com/a/44478894)
2) [mysqldump Flags](https://mariadb.com/kb/en/library/mysqldump/)
3) [mysqldump Password Env Variable](https://stackoverflow.com/a/34670902)
4) [Executing Bash from Python](https://docs.python.org/3/library/subprocess.html#subprocess.run)
5) [Upload S3 Object Boto3](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/s3.html#S3.Client.upload_file)
6) [Make Bash Executable AWS Lambda](https://stackoverflow.com/a/48196444)
7) [Executables AWS Lambda](https://aws.amazon.com/blogs/compute/running-executables-in-aws-lambda/)