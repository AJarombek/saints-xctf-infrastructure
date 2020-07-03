"""
Functions which represent Unit tests for Secrets Manager credentials
Author: Andrew Jarombek
Date: 9/12/2019
"""

import unittest
import os

import boto3

try:
    prod_env = os.environ['TEST_ENV'] == "prod"
except KeyError:
    prod_env = True


class TestSecretsManager(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.secrets_manager = boto3.client('secretsmanager')
        self.prod_env = prod_env

    @unittest.skipIf(prod_env == 'dev', 'No RDS secret created in development.')
    def test_rds_secrets_exist(self):
        """
        Test that the SaintsXCTF production RDS instance credentials exist in Secrets Manager.
        """
        if self.prod_env:
            secret_id = 'saints-xctf-rds-prod-secret'
            description = 'SaintsXCTF MySQL RDS Login Credentials for the PROD Environment'
        else:
            secret_id = 'saints-xctf-rds-dev-secret'
            description = 'SaintsXCTF MySQL RDS Login Credentials for the DEV Environment'

        credentials = self.secrets_manager.describe_secret(SecretId=secret_id)
        self.assertTrue(all([
            credentials.get('Name') == secret_id,
            credentials.get('Description') == description,
        ]))
