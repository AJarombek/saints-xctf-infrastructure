"""
Unit tests for the saintsxctf.com (and dev.saintsxctf.com) AWS infrastructure which exists alongside the websites
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
    prod_env = os.environ["TEST_ENV"] == "prod"
except KeyError:
    prod_env = True


class TestSXCTF(unittest.TestCase):
    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.ecr: ECRClient = boto3.client("ecr", region_name="us-east-1")
        self.prod_env = prod_env

    def test_saints_xctf_web_base_ecr_repository(self) -> None:
        """
        Ensure that the saints-xctf-web-base ECR repository exists.
        """
        repos = self.ecr.describe_repositories(repositoryNames=["saints-xctf-web-base"])
        repositories: List[dict] = repos.get("repositories")
        self.assertEqual(1, len(repositories))

    def test_saints_xctf_web_base_ecr_repository_contains_images(self) -> None:
        """
        Prove that the saints-xctf-web-base ECR repository contains one or more Docker container images.
        """
        images = self.ecr.describe_images(repositoryName="saints-xctf-web-base")
        image_list: List[dict] = images.get("imageDetails")
        self.assertLessEqual(1, len(image_list))

    def test_saints_xctf_web_nginx_ecr_repository(self) -> None:
        """
        Ensure that the saints-xctf-web-nginx ECR repository exists.
        """
        repos = self.ecr.describe_repositories(
            repositoryNames=["saints-xctf-web-nginx"]
        )
        repositories: List[dict] = repos.get("repositories")
        self.assertEqual(1, len(repositories))

    @unittest.skipIf(not prod_env, "These images are for production only.")
    def test_saints_xctf_web_nginx_ecr_repository_contains_images(self) -> None:
        """
        Prove that the saints-xctf-web-nginx ECR repository contains one or more Docker container images.
        """
        images = self.ecr.describe_images(repositoryName="saints-xctf-web-nginx")
        image_list: List[dict] = images.get("imageDetails")
        self.assertLessEqual(1, len(image_list))

    def test_saints_xctf_web_nginx_dev_ecr_repository(self) -> None:
        """
        Ensure that the saints-xctf-web-nginx-dev ECR repository exists.
        """
        repos = self.ecr.describe_repositories(
            repositoryNames=["saints-xctf-web-nginx-dev"]
        )
        repositories: List[dict] = repos.get("repositories")
        self.assertEqual(1, len(repositories))

    @unittest.skipIf(not prod_env, "These images are for development only.")
    def test_saints_xctf_web_nginx_dev_ecr_repository_contains_images(self) -> None:
        """
        Prove that the saints-xctf-web-nginx-dev ECR repository contains one or more Docker container images.
        """
        images = self.ecr.describe_images(repositoryName="saints-xctf-web-nginx-dev")
        image_list: List[dict] = images.get("imageDetails")
        self.assertLessEqual(1, len(image_list))
