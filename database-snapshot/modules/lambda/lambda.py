"""
Lambda function for RDS snapshots
Author: Andrew Jarombek
Date: 6/8/2019
"""

import os
import boto3
import json
import subprocess


def take_snapshot(event, context):

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

    subprocess.call("backup.sh", shell=True)

    return True
