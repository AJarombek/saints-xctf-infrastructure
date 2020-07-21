"""
Lambda function for RDS restoration from a backup
Author: Andrew Jarombek
Date: 7/18/2020
"""

import os
import boto3
import botocore.config
import json
import subprocess


def restore(event, context):
    """
    Restore an RDS MySQL database from a backup on S3
    :param event: provides information about the triggering of the function
    :param context: provides information about the execution environment
    :return: True when successful
    """

    # Set the path to the executable scripts in the AWS Lambda environment.
    # Source: https://aws.amazon.com/blogs/compute/running-executables-in-aws-lambda/
    os.environ['PATH'] = os.environ['PATH'] + ':' + os.environ['LAMBDA_TASK_ROOT']

    try:
        env = os.environ['ENV']
    except KeyError:
        env = "prod"

    try:
        host = os.environ['DB_HOST']
    except KeyError:
        host = ""

    secretsmanager = boto3.client('secretsmanager')
    response = secretsmanager.get_secret_value(SecretId=f'saints-xctf-rds-{env}-secret')
    secret_string = response.get("SecretString")
    secret_dict = json.loads(secret_string)

    username = secret_dict.get("username")
    password = secret_dict.get("password")

    # By default, S3 resolves buckets using the internet.  To use the VPC endpoint instead, use the 'path' addressing
    # style config.  Source: https://stackoverflow.com/a/44478894
    s3 = boto3.resource('s3', 'us-east-1', config=botocore.config.Config(s3={'addressing_style': 'path'}))

    s3.meta.client.download_file(f'saints-xctf-db-backups-{env}', 'backup.sql', '/tmp/backup.sql')

    # To execute the bash script on AWS Lambda, change its permissions and move it into the /tmp/ directory.
    subprocess.check_call(["cp ./restore.sh /tmp/restore.sh && chmod 755 /tmp/restore.sh"], shell=True)
    subprocess.check_call(["cp ./mysql /tmp/mysql && chmod 755 /tmp/mysql"], shell=True)

    subprocess.check_call(["/tmp/restore.sh", env, host, username, password])

    return True
