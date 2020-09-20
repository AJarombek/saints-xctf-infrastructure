"""
Unit tests for RDS database backup infrastructure.
Author: Andrew Jarombek
Date: 9/19/2020
"""

import unittest
import os

import boto3
from boto3_type_annotations.s3 import Client as S3Client

try:
    prod_env = os.environ['TEST_ENV'] == "prod"
except KeyError:
    prod_env = True


class TestDatabaseBackup(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.s3: S3Client = boto3.client('s3')
        self.prod_env = prod_env

    def test_saints_xctf_backups_s3_bucket_exists(self) -> None:
        """
        Test if a saints-xctf-db-backups S3 bucket exists
        """
        if prod_env:
            bucket_name = 'saints-xctf-db-backups-prod'
        else:
            bucket_name = 'saints-xctf-db-backups-dev'

        s3_bucket = self.s3.list_objects(Bucket=bucket_name)
        self.assertTrue(s3_bucket.get('Name') == bucket_name)
