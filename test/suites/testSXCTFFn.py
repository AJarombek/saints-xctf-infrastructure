"""
Unit tests for the fn.saintsxctf.com API Gateway REST API.
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
from utils.IAM import IAM

try:
    prod_env = os.environ['TEST_ENV'] == "prod"
except KeyError:
    prod_env = True


class TestSXCTFFn(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.apigateway: ApiGatewayClient = boto3.client('apigateway', region_name='us-east-1')
        self.lambda_: LambdaClient = boto3.client('lambda', region_name='us-east-1')
        self.prod_env = prod_env

        if self.prod_env:
            self.api_name = 'saints-xctf-com-fn-dev'
        else:
            self.api_name = 'saints-xctf-com-fn-dev'

    @unittest.skipIf(prod_env, 'Production Function API not running.')
    def test_fn_saintsxctf_com_api_exists(self) -> None:
        """
        Test if the fn.saintsxctf.com API Gateway REST API exists
        """
        APIGateway.rest_api_exists(self, self.api_name)

    @unittest.skipIf(prod_env, 'Production Function API not running.')
    def test_fn_saintsxctf_com_api_deployment_exists(self) -> None:
        """
        Test if a deployment exists for the fn.saintsxctf.com API Gateway REST API.
        """
        APIGateway.deployment_exists(self, self.api_name)

    @unittest.skipIf(prod_env, 'Production Function API not running.')
    def test_fn_saintsxctf_com_api_stage_exists(self) -> None:
        """
        Test if a stage (named reference to a deployment) exists for the fn.saintsxctf.com API Gateway REST API.
        """
        if self.prod_env:
            stage_name = 'production'
        else:
            stage_name = 'development'

        APIGateway.stage_exists(self, self.api_name, stage_name)

    @unittest.skipIf(prod_env, 'Production Function API not running.')
    def test_fn_saintsxctf_com_api_authorizer_exists(self) -> None:
        """
        Test if a lambda authorizer exists for the fn.saintsxctf.com REST API.
        """
        api_id = APIGateway.rest_api_exists(self, self.api_name)
        authorizers = self.apigateway.get_authorizers(restApiId=api_id)
        authorizer_list: List[dict] = authorizers.get('items')
        self.assertEqual(1, len(authorizer_list))

        authorizer: dict = authorizer_list[0]
        self.assertEqual('saints-xctf-com-fn-auth', authorizer.get('name'))
        self.assertEqual('TOKEN', authorizer.get('type'))

        if self.prod_env:
            authorizer_name = 'function:SaintsXCTFAuthorizer/invocations'
        else:
            authorizer_name = 'function:SaintsXCTFAuthorizerDEV/invocations'

        self.assertTrue(authorizer_name in authorizer.get('authorizerUri'))

    @unittest.skipIf(prod_env, 'Production Function API not running.')
    def test_fn_saintsxctf_com_api_domain_name_exists(self) -> None:
        """
        Test that a domain name is configured for the fn.saintsxctf.com REST API.
        """
        if self.prod_env:
            domain_name = 'fn.saintsxctf.com'
        else:
            domain_name = 'dev.fn.saintsxctf.com'

        domain = self.apigateway.get_domain_name(domainName=domain_name)
        self.assertEqual('AVAILABLE', domain.get('domainNameStatus'))

    @unittest.skipIf(prod_env, 'Production Function API not running.')
    def test_fn_saintsxctf_com_api_base_path_mapping_empty(self) -> None:
        """
        Test that an empty string is configured for the base path mapping of the fn.saintsxctf.com REST API.
        """
        if self.prod_env:
            domain_name = 'fn.saintsxctf.com'
        else:
            domain_name = 'dev.fn.saintsxctf.com'

        base_path_mappings = self.apigateway.get_base_path_mappings(domainName=domain_name)
        base_path_mapping_list: List[dict] = base_path_mappings.get('items')
        self.assertEqual(1, len(base_path_mapping_list))

        base_path_mapping = base_path_mapping_list[0]
        self.assertEqual('(none)', base_path_mapping.get('basePath'))

    def test_api_gateway_auth_role_exists(self) -> None:
        """
        Test that the api-gateway-auth-role IAM Role exists.
        """
        self.assertTrue(IAM.iam_role_exists(role_name='api-gateway-auth-role'))

    def test_api_gateway_auth_policy_attached(self) -> None:
        """
        Test that the api-gateway-auth-policy is attached to the api-gateway-auth-role
        """
        self.assertTrue(IAM.iam_policy_attached_to_role(
            role_name='api-gateway-auth-role',
            policy_name='api-gateway-auth-policy'
        ))
