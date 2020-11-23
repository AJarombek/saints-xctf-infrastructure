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
        apis: dict = self.apigateway.get_rest_apis()
        api_list: List[dict] = apis.get('items')
        matching_apis = [api for api in api_list if api.get('name') == self.api_name]
        self.assertEqual(1, len(matching_apis))

    @unittest.skipIf(prod_env, 'Production Function API not running.')
    def test_fn_saintsxctf_com_api_deployment_exists(self) -> None:
        """
        Test if a deployment exists for the fn.saintsxctf.com API Gateway REST API.
        """
        apis: dict = self.apigateway.get_rest_apis()
        api_list: List[dict] = apis.get('items')
        matching_apis = [api for api in api_list if api.get('name') == self.api_name]
        self.assertEqual(1, len(matching_apis))

        api_id = matching_apis[0].get('id')
        deployments = self.apigateway.get_deployments(restApiId=api_id)
        deployment_list: List[dict] = deployments.get('items')
        self.assertEqual(1, len(deployment_list))
