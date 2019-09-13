"""
Functions which represent Unit tests for Secrets Manager credentials
Author: Andrew Jarombek
Date: 9/12/2019
"""

import boto3

secrets_manager = boto3.client('secretsmanager')


def prod_rds_secrets_exist():
    credentials = secrets_manager.describe_secret(SecretId='saints-xctf-rds-prod-secret')
    return all([
        credentials.get('Name') == 'saints-xctf-rds-prod-secret',
        credentials.get('Description') == 'SaintsXCTF MySQL RDS Login Credentials for the PROD Environment',
    ])


def dev_rds_secrets_exist():
    credentials = secrets_manager.describe_secret(SecretId='saints-xctf-rds-dev-secret')
    return all([
        credentials.get('Name') == 'saints-xctf-rds-dev-secret',
        credentials.get('Description') == 'SaintsXCTF MySQL RDS Login Credentials for the DEV Environment',
    ])
