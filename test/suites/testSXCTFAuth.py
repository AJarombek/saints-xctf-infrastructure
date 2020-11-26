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

from aws_test_functions.APIGateway import APIGateway
from aws_test_functions.Route53 import Route53

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
            self.domain_name = 'auth.saintsxctf.com'
        else:
            self.api_name = 'saints-xctf-com-auth-dev'
            self.domain_name = 'dev.auth.saintsxctf.com'

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

    @unittest.skipIf(prod_env, 'Production Auth API not running.')
    def test_auth_saintsxctf_com_api_route53_record_exists(self) -> None:
        """
        Determine if an 'A' record exists for 'auth.saintsxctf.com.' in Route53
        """
        try:
            a_record = Route53.get_record(f'saintsxctf.com.', f'{self.domain_name}.', 'A')
        except IndexError:
            self.assertTrue(False)
            return

        self.assertTrue(a_record.get('Name') == f'{self.domain_name}.' and a_record.get('Type') == 'A')

    @unittest.skipIf(prod_env, 'Production Auth API not running.')
    def test_auth_saintsxctf_com_api_has_expected_endpoints(self) -> None:
        """
        Test that the expected endpoints exist in 'auth.saintsxctf.com.'.
        """
        pass

    @unittest.skipIf(prod_env, 'Production Auth API not running.')
    def test_auth_saintsxctf_com_api_token_endpoint(self) -> None:
        """
        Test that the '/token' endpoint exists in 'auth.saintsxctf.com.' as expected.
        """
        pass

    @unittest.skipIf(prod_env, 'Production Auth API not running.')
    def test_auth_saintsxctf_com_api_authenticate_endpoint(self) -> None:
        """
        Test that the '/authenticate' endpoint exists in 'auth.saintsxctf.com.' as expected.
        """
        pass
