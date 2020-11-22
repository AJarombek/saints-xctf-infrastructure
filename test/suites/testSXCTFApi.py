"""
Unit tests for the api.saintsxctf.com (and dev.api.saintsxctf.com) AWS infrastructure which exists alongside the APIs
Kubernetes infrastructure.
Author: Andrew Jarombek
Date: 11/22/2020
"""

import unittest
import os
from typing import List

import boto3
from boto3_type_annotations.ecr import Client as ECRClient

try:
    prod_env = os.environ['TEST_ENV'] == "prod"
except KeyError:
    prod_env = True


class TestSXCTFApi(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.ecr: ECRClient = boto3.client('ecr', region_name='us-east-1')
        self.prod_env = prod_env

    def test_saints_xctf_api_flask_ecr_repository(self) -> None:
        """
        Ensure that the saints-xctf-api-flask ECR repository exists.
        """
        repos = self.ecr.describe_repositories(repositoryNames=['saints-xctf-api-flask'])
        repositories: List[dict] = repos.get('repositories')
        self.assertEqual(1, len(repositories))

    def test_saints_xctf_api_flask_ecr_repository_contains_images(self) -> None:
        """
        Prove that the saints-xctf-api-flask ECR repository contains one or more Docker container images.
        """
        images = self.ecr.describe_images(repositoryName='saints-xctf-api-flask')
        image_list: List[dict] = images.get('imageDetails')
        self.assertLessEqual(1, len(image_list))

    def test_saints_xctf_api_nginx_ecr_repository(self) -> None:
        """
        Ensure that the saints-xctf-api-nginx ECR repository exists.
        """
        repos = self.ecr.describe_repositories(repositoryNames=['saints-xctf-api-nginx'])
        repositories: List[dict] = repos.get('repositories')
        self.assertEqual(1, len(repositories))

    def test_saints_xctf_api_nginx_ecr_repository_contains_images(self) -> None:
        """
        Prove that the saints-xctf-api-nginx ECR repository contains one or more Docker container images.
        """
        images = self.ecr.describe_images(repositoryName='saints-xctf-api-nginx')
        image_list: List[dict] = images.get('imageDetails')
        self.assertLessEqual(1, len(image_list))
