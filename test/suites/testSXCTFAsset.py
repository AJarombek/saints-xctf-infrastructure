"""
Unit tests for the asset.saintsxctf.com S3 bucket
Author: Andrew Jarombek
Date: 7/3/2020
"""

import unittest
import os

import boto3
from boto3_type_annotations.s3 import Client as S3Client
from boto3_type_annotations.cloudfront import Client as CloudFrontClient

try:
    prod_env = os.environ["TEST_ENV"] == "prod"
except KeyError:
    prod_env = True


class TestSXCTFAsset(unittest.TestCase):
    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.s3: S3Client = boto3.client("s3")
        self.cloudfront: CloudFrontClient = boto3.client("cloudfront")
        self.prod_env = prod_env
        self.bucket_name = "asset.saintsxctf.com"

    def test_asset_saintsxctf_s3_bucket_exists(self) -> None:
        """
        Test if an asset.saintsxctf.com S3 bucket exists
        """
        s3_bucket = self.s3.list_objects(Bucket=self.bucket_name)
        self.assertTrue(s3_bucket.get("Name") == self.bucket_name)

    def test_asset_saintsxctf_s3_bucket_public_access(self) -> None:
        """
        Test whether the public access configuration for a asset.saintsxctf.com S3 bucket is correct
        """
        public_access_block = self.s3.get_public_access_block(Bucket=self.bucket_name)
        config = public_access_block.get("PublicAccessBlockConfiguration")
        self.assertTrue(config.get("BlockPublicAcls"))
        self.assertTrue(config.get("IgnorePublicAcls"))
        self.assertTrue(config.get("BlockPublicPolicy"))
        self.assertTrue(config.get("RestrictPublicBuckets"))

    def test_s3_bucket_objects_correct(self) -> None:
        """
        Test if the S3 bucket for asset.saintsxctf.com contains the proper objects
        """
        contents = self.s3.list_objects(Bucket=self.bucket_name).get("Contents")
        self.assertTrue(
            all(
                [
                    len(contents) == 11,
                    contents[0].get("Key") == "amazon-app-store.png",
                    contents[1].get("Key") == "app-store.png",
                    contents[2].get("Key") == "ben-f.jpg",
                    contents[3].get("Key") == "evan-g.jpg",
                    contents[4].get("Key") == "google-play-store.svg",
                    contents[5].get("Key") == "joe-s.jpg",
                    contents[6].get("Key") == "lisa-g.jpg",
                    contents[7].get("Key") == "saintsxctf-vid.mp4",
                    contents[8].get("Key") == "saintsxctf.png",
                    contents[9].get("Key") == "thomas-c.jpg",
                    contents[10].get("Key") == "trevor-b.jpg",
                ]
            )
        )

    def test_s3_bucket_cloudfront_distributed(self) -> None:
        """
        Ensure that the asset.saintsxctf.com S3 bucket is distributed with CloudFront as expected
        """
        distributions = self.cloudfront.list_distributions()
        dist_list = distributions.get("DistributionList").get("Items")
        dists = [
            item
            for item in dist_list
            if item.get("Aliases").get("Items")[0] in ["asset.saintsxctf.com"]
        ]

        self.assertEqual(1, len(dists))

        for dist in dists:
            self.assertTrue(
                all(
                    [
                        dist.get("Status") == "Deployed",
                        dist.get("DefaultCacheBehavior")
                        .get("AllowedMethods")
                        .get("Quantity")
                        == 3,
                        dist.get("DefaultCacheBehavior")
                        .get("AllowedMethods")
                        .get("Items")[0]
                        == "HEAD",
                        dist.get("DefaultCacheBehavior")
                        .get("AllowedMethods")
                        .get("Items")[1]
                        == "GET",
                        dist.get("DefaultCacheBehavior")
                        .get("AllowedMethods")
                        .get("Items")[2]
                        == "OPTIONS",
                        dist.get("DefaultCacheBehavior")
                        .get("AllowedMethods")
                        .get("CachedMethods")
                        .get("Quantity")
                        == 3,
                        dist.get("DefaultCacheBehavior")
                        .get("AllowedMethods")
                        .get("CachedMethods")
                        .get("Items")[0]
                        == "HEAD",
                        dist.get("DefaultCacheBehavior")
                        .get("AllowedMethods")
                        .get("CachedMethods")
                        .get("Items")[1]
                        == "GET",
                        dist.get("DefaultCacheBehavior")
                        .get("AllowedMethods")
                        .get("CachedMethods")
                        .get("Items")[2]
                        == "OPTIONS",
                        dist.get("Restrictions")
                        .get("GeoRestriction")
                        .get("RestrictionType")
                        == "none",
                        dist.get("HttpVersion") == "HTTP2",
                    ]
                )
            )
