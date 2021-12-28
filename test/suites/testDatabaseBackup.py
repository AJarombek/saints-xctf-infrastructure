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

        if prod_env:
            self.bucket_name = 'saints-xctf-db-backups-prod'
        else:
            self.bucket_name = 'saints-xctf-db-backups-dev'

    def test_saints_xctf_backups_s3_bucket_exists(self) -> None:
        """
        Test if a saints-xctf-db-backups S3 bucket exists
        """
        s3_bucket = self.s3.list_objects(Bucket=self.bucket_name)
        self.assertTrue(s3_bucket.get('Name') == self.bucket_name)

    def test_saints_xctf_backups_s3_bucket_public_access(self) -> None:
        """
        Test whether the public access configuration for a saints-xctf-db-backups S3 bucket is correct
        """
        public_access_block = self.s3.get_public_access_block(Bucket=self.bucket_name)
        config = public_access_block.get('PublicAccessBlockConfiguration')
        self.assertTrue(config.get('BlockPublicAcls'))
        self.assertTrue(config.get('IgnorePublicAcls'))
        self.assertTrue(config.get('BlockPublicPolicy'))
        self.assertTrue(config.get('RestrictPublicBuckets'))
