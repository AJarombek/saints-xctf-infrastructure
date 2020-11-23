"""
Helper functions for AWS API Gateway tests.
Author: Andrew Jarombek
Date: 11/22/2020
"""

import unittest
from typing import List

import boto3
from boto3_type_annotations.apigateway import Client as APIGatewayClient

apigateway: APIGatewayClient = boto3.client('apigateway', region_name='us-east-1')


class APIGateway:

    @staticmethod
    def rest_api_exists(test_case: unittest.TestCase, api_name: str) -> str:
        """
        Test that an AWS API Gateway REST API exists.
        :param test_case: Instance of a unittest test case.  This object is used to make assertions.
        :param api_name: The name of the REST API.
        :return: The REST API's id.
        """
        apis: dict = apigateway.get_rest_apis()
        api_list: List[dict] = apis.get('items')
        matching_apis = [api for api in api_list if api.get('name') == api_name]
        test_case.assertEqual(1, len(matching_apis))

        return matching_apis[0].get('id')

    @staticmethod
    def deployment_exists(test_case: unittest.TestCase, api_name: str, api_id: str = None) -> str:
        """
        Test that a deployment of an AWS API Gateway REST API exists.
        :param test_case: Instance of a unittest test case.  This object is used to make assertions.
        :param api_name: The name of the REST API.
        :param api_id: An optional API id for the REST API.
        :return: The REST API deployment's id.
        """
        if not api_id:
            api_id = APIGateway.rest_api_exists(test_case, api_name)

        deployments = apigateway.get_deployments(restApiId=api_id)
        deployment_list: List[dict] = deployments.get('items')
        test_case.assertEqual(1, len(deployment_list))

        return deployment_list[0].get('id')

    @staticmethod
    def stage_exists(test_case: unittest.TestCase, api_name: str, stage_name: str) -> None:
        """
        Test that a deployment of an AWS API Gateway REST API exists.
        :param test_case: Instance of a unittest test case.  This object is used to make assertions.
        :param api_name: The name of the REST API.
        :param stage_name: Name of the stage (which is a reference to a deployment) for a REST API.
        """
        api_id = APIGateway.rest_api_exists(test_case, api_name)
        deployment_id = APIGateway.deployment_exists(test_case, api_name, api_id)

        stages = apigateway.get_stages(restApiId=api_id, deploymentId=deployment_id)
        stage_list: List[dict] = stages.get('item')
        matching_stages = [stage for stage in stage_list if stage.get('stageName') == stage_name]
        test_case.assertEqual(1, len(matching_stages))
