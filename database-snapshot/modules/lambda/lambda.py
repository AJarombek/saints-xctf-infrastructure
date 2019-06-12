"""
Lambda function for RDS snapshots
Author: Andrew Jarombek
Date: 6/8/2019
"""

import os
import boto3
import json
import subprocess


def create_backup(event, context):
    """
    Create a backup of an RDS MySQL database and store it on S3
    :param event: provides information about the triggering of the function
    :param context: provides information about the execution environment
    :return: True when successful
    """

    try:
        env = os.environ['ENV']
    except KeyError:
        env = "prod"

    secretsmanager = boto3.client('secretsmanager')
    response = secretsmanager.get_secret_value(SecretId=f'saints-xctf-rds-{env}-secret')
    secret_string = response.get("SecretString")
    secret_dict = json.loads(secret_string)

    username = secret_dict.get("username")
    password = secret_dict.get("password")

    host = None  # TODO

    subprocess.check_call(["backup.sh", env, host, username, password], shell=True)

    return True
