"""
Unit tests for AWS CloudWatch Synthetic Monitoring canary functions.
Author: Andrew Jarombek
Date: 7/8/2021
"""

import unittest
import os
from typing import Dict, Any

import boto3
from boto3_type_annotations.s3 import Client as S3Client

from aws_test_functions.IAM import IAM

try:
    prod_env = os.environ['TEST_ENV'] == "prod"
except KeyError:
    prod_env = True


class TestSyntheticMonitoring(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.s3: S3Client = boto3.client('s3', region_name='us-east-1')
        self.synthetics = boto3.client('synthetics', region_name='us-east-1')
        self.prod_env = prod_env

        if self.prod_env:
            self.env = 'prod'
        else:
            self.env = 'dev'

    def test_canary_role_exists(self) -> None:
        """
        Test that the canary-role IAM Role exists.
        """
        self.assertTrue(IAM.iam_role_exists(role_name=f'canary-role'))

    def test_canary_policy_attached(self) -> None:
        """
        Test that the canary-policy is attached to the canary-role
        """
        self.assertTrue(IAM.iam_policy_attached_to_role(
            role_name=f'canary-role',
            policy_name=f'canary-policy'
        ))

    def test_saints_xctf_canaries_s3_bucket_exists(self) -> None:
        """
        Test if a saints-xctf-canaries S3 bucket exists
        """
        s3_bucket = self.s3.list_objects(Bucket='saints-xctf-canaries')
        self.assertTrue(s3_bucket.get('Name') == 'saints-xctf-canaries')

    @unittest.skipIf(not prod_env, 'Development SaintsXCTF Up canary function not under test.')
    def test_sxctf_up_canary_function_exists(self):
        response = self.synthetics.get_canary(Name=f'sxctf-up-{self.env}')
        canary: Dict[str, Any] = response.get('Canary')

        self.assertEqual(canary.get('Name'), f'sxctf-up-{self.env}')
        self.assertEqual(canary.get('RuntimeVersion'), 'syn-nodejs-puppeteer-3.1')
        self.assertEqual(canary.get('ArtifactS3Location'), 'saints-xctf-canaries/')
        self.assertEqual(canary.get('SuccessRetentionPeriodInDays'), 2)
        self.assertEqual(canary.get('FailureRetentionPeriodInDays'), 14)
        self.assertEqual(canary.get('Code').get('Handler'), 'up.handler')
        self.assertEqual(canary.get('Schedule').get('Expression'), 'rate(1 hour)')

    @unittest.skipIf(not prod_env, 'Development SaintsXCTF Sign In canary function not under test.')
    def test_sxctf_sign_in_canary_function_exists(self):
        response = self.synthetics.get_canary(Name=f'sxctf-sign-in-{self.env}')
        canary: Dict[str, Any] = response.get('Canary')

        self.assertEqual(canary.get('Name'), f'sxctf-sign-in-{self.env}')
        self.assertEqual(canary.get('RuntimeVersion'), 'syn-nodejs-puppeteer-3.1')
        self.assertEqual(canary.get('ArtifactS3Location'), 'saints-xctf-canaries/')
        self.assertEqual(canary.get('SuccessRetentionPeriodInDays'), 2)
        self.assertEqual(canary.get('FailureRetentionPeriodInDays'), 14)
        self.assertEqual(canary.get('Code').get('Handler'), 'signIn.handler')
        self.assertEqual(canary.get('Schedule').get('Expression'), 'rate(1 hour)')
