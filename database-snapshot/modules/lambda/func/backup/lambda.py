"""
Lambda function for RDS snapshots
Author: Andrew Jarombek
Date: 6/8/2019
"""

import os
import boto3
import botocore.config
import json
import subprocess


def create_backup(event, context):
    """
    Create a backup of an RDS MySQL database and store it on S3
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

    # To execute the bash script on AWS Lambda, change its permissions and move it into the /tmp/ directory.
    # Source: https://stackoverflow.com/a/48196444
    subprocess.check_call(["cp ./backup.sh /tmp/backup.sh && chmod 755 /tmp/backup.sh"], shell=True)

    subprocess.check_call(["/tmp/backup.sh", env, host, username, password])

    # By default, S3 resolves buckets using the internet.  To use the VPC endpoint instead, use the 'path' addressing
    # style config.  Source: https://stackoverflow.com/a/44478894
    s3 = boto3.resource('s3', 'us-east-1', config=botocore.config.Config(s3={'addressing_style':'path'}))

    s3.meta.client.upload_file('/tmp/backup.sql', f'saints-xctf-db-backups-{env}', 'backup.sql')

    return True
