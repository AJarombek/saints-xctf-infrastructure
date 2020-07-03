"""
Unit tests for the uasset.saintsxctf.com S3 bucket
Author: Andrew Jarombek
Date: 7/3/2020
"""

import unittest
import os

import boto3
from boto3_type_annotations.s3 import Client as S3Client
from boto3_type_annotations.cloudfront import Client as CloudFrontClient

try:
    prod_env = os.environ['TEST_ENV'] == "prod"
except KeyError:
    prod_env = True


class TestSXCTFAsset(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.s3: S3Client = boto3.client('s3')
        self.cloudfront: CloudFrontClient = boto3.client('cloudfront')
        self.prod_env = prod_env

    def test_uasset_saintsxctf_s3_bucket_exists(self) -> None:
        """
        Test if an uasset.saintsxctf.com S3 bucket exists
        """
        bucket_name = 'uasset.saintsxctf.com'
        s3_bucket = self.s3.list_objects(Bucket=bucket_name)
        self.assertTrue(s3_bucket.get('Name') == bucket_name)

    def test_s3_bucket_cloudfront_distributed(self) -> None:
        """
        Ensure that the uasset.saintsxctf.com S3 bucket is distributed with CloudFront as expected
        """
        distributions = self.cloudfront.list_distributions()
        dist_list = distributions.get('DistributionList').get('Items')
        dist = [item for item in dist_list if item.get('Aliases').get('Items')[0] == 'uasset.saintsxctf.com'][0]

        self.assertTrue(all([
            dist.get('Status') == 'Deployed',
            dist.get('DefaultCacheBehavior').get('AllowedMethods').get('Quantity') == 2,
            dist.get('DefaultCacheBehavior').get('AllowedMethods').get('Items')[0] == 'HEAD',
            dist.get('DefaultCacheBehavior').get('AllowedMethods').get('Items')[1] == 'GET',
            dist.get('Restrictions').get('GeoRestriction').get('RestrictionType') == 'none',
            dist.get('HttpVersion') == 'HTTP2'
        ]))