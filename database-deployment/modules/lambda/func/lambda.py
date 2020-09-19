"""
Lambda function for database deployments.
Author: Andrew Jarombek
Date: 9/17/2020
"""

import os
import boto3
import botocore.config
import json
import subprocess


def deploy(event, context):
    """
    Deploy a SQL script in an S3 bucket to an RDS MySQL database.
    :param event: provides information about the triggering of the function
    :param context: provides information about the execution environment
    :return: True when successful
    """
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

    s3 = boto3.resource('s3', 'us-east-1', config=botocore.config.Config(s3={'addressing_style': 'path'}))
    s3.meta.client.download_file(f'saints-xctf-database-deployments', event['file_path'], '/tmp/script.sql')

    # To execute the bash script on AWS Lambda, change its permissions and move it into the /tmp/ directory.
    subprocess.check_call(["cp ./deploy.sh /tmp/deploy.sh && chmod 755 /tmp/deploy.sh"], shell=True)
    subprocess.check_call(["cp ./mysql /tmp/mysql && chmod 755 /tmp/mysql"], shell=True)

    subprocess.check_call(["/tmp/deploy.sh", env, host, username, password])

    return True