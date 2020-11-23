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

    #@unittest.skipIf(prod_env, 'Production Function API not running.')
    def test_fn_saintsxctf_com_api_stage_exists(self) -> None:
        """
        Test if a stage (named reference to a deployment) exists for the fn.saintsxctf.com API Gateway REST API.
        """
        if self.prod_env:
            stage_name = 'production'
        else:
            stage_name = 'development'

        APIGateway.stage_exists(self, self.api_name, stage_name)

