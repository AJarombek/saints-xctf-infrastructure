"""
Unit tests for the auth.saintsxctf.com API Gateway REST API.
Author: Andrew Jarombek
Date: 11/22/2020
"""

import unittest
import os
from typing import List

import boto3
from boto3_type_annotations.apigateway import Client as ApiGatewayClient
from boto3_type_annotations.lambda_ import Client as LambdaClient

from utils.APIGateway import APIGateway

try:
    prod_env = os.environ['TEST_ENV'] == "prod"
except KeyError:
    prod_env = True


class TestSXCTFAuth(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.apigateway: ApiGatewayClient = boto3.client('apigateway', region_name='us-east-1')
        self.lambda_: LambdaClient = boto3.client('lambda', region_name='us-east-1')
        self.prod_env = prod_env

        if self.prod_env:
            self.api_name = 'saints-xctf-com-auth'
        else:
            self.api_name = 'saints-xctf-com-auth-dev'

    @unittest.skipIf(prod_env, 'Production Auth API not running.')
    def test_auth_saintsxctf_com_api_exists(self) -> None:
        """
        Test if the auth.saintsxctf.com API Gateway REST API exists
        """
        APIGateway.rest_api_exists(self, self.api_name)

    @unittest.skipIf(prod_env, 'Production Auth API not running.')
    def test_auth_saintsxctf_com_api_deployment_exists(self) -> None:
        """
        Test if a deployment exists for the auth.saintsxctf.com API Gateway REST API.
        """
        APIGateway.deployment_exists(self, self.api_name)

    @unittest.skipIf(prod_env, 'Production Auth API not running.')
    def test_auth_saintsxctf_com_api_stage_exists(self) -> None:
        """
        Test if a stage (named reference to a deployment) exists for the auth.saintsxctf.com API Gateway REST API.
        """
        if self.prod_env:
            stage_name = 'production'
        else:
            stage_name = 'development'

        APIGateway.stage_exists(self, self.api_name, stage_name)

    @unittest.skipIf(prod_env, 'Production Auth API not running.')
    def test_auth_saintsxctf_com_api_domain_name_exists(self) -> None:
        """
        Test that a domain name is configured for the auth.saintsxctf.com REST API.
        """
        if self.prod_env:
            domain_name = 'auth.saintsxctf.com'
        else:
            domain_name = 'dev.auth.saintsxctf.com'

        domain = self.apigateway.get_domain_name(domainName=domain_name)
        self.assertEqual('AVAILABLE', domain.get('domainNameStatus'))

    @unittest.skipIf(prod_env, 'Production Auth API not running.')
    def test_auth_saintsxctf_com_api_base_path_mapping_empty(self) -> None:
        """
        Test that an empty string is configured for the base path mapping of the auth.saintsxctf.com REST API.
        """
        if self.prod_env:
            domain_name = 'auth.saintsxctf.com'
        else:
            domain_name = 'dev.auth.saintsxctf.com'

        base_path_mappings = self.apigateway.get_base_path_mappings(domainName=domain_name)
        base_path_mapping_list: List[dict] = base_path_mappings.get('items')
        self.assertEqual(1, len(base_path_mapping_list))

        base_path_mapping = base_path_mapping_list[0]
        self.assertEqual('(none)', base_path_mapping.get('basePath'))
