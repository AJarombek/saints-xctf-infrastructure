"""
Functions which represent Unit tests for single aspects of the Web Application module
Author: Andrew Jarombek
Date: 3/17/2019
"""

import unittest
import os

import boto3


class TestRoute53(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.s3 = boto3.client('s3')

        try:
            self.prod_env = os.environ['TEST_ENV'] == "prod"
        except KeyError:
            self.prod_env = True

    def test_s3_bucket_exists(self) -> None:
        """
        Test if an S3 bucket for prod environment credentials exists
        :return: True if the bucket exists, False otherwise
        """
        if self.prod_env:
            bucket_name = 'saints-xctf-credentials-prod'
        else:
            bucket_name = 'saints-xctf-credentials-dev'

        s3_bucket = self.s3.list_objects(Bucket=bucket_name)
        return s3_bucket.get('Name') == bucket_name

    def test_s3_bucket_objects_correct(self) -> None:
        """
        Test if the S3 bucket for prod contains the proper objects
        :return: True if the objects are as expected, False otherwise
        """
        if self.prod_env:
            bucket_name = 'saints-xctf-credentials-prod'
        else:
            bucket_name = 'saints-xctf-credentials-dev'

        contents = self.s3.list_objects(Bucket=bucket_name).get('Contents')
        self.assertTrue(all([
            len(contents) == 4,
            contents[0].get('Key') == 'api/apicred.php',
            contents[1].get('Key') == 'api/cred.php',
            contents[2].get('Key') == 'date.js',
            contents[3].get('Key') == 'models/clientcred.php'
        ]))