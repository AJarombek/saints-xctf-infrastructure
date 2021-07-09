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
from aws_test_functions.Lambda import Lambda
from aws_test_functions.IAM import IAM
from aws_test_functions.VPC import VPC
from aws_test_functions.CloudWatchLogs import CloudWatchLogs

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
            self.env = 'prod'
        else:
            self.api_name = 'saints-xctf-com-auth-dev'
            self.domain_name = 'dev.auth.saintsxctf.com'
            self.env = 'dev'

    @unittest.skipIf(not prod_env, 'Development Auth API not under test.')
    def test_auth_saintsxctf_com_api_exists(self) -> None:
        """
        Test if the auth.saintsxctf.com API Gateway REST API exists
        """
        APIGateway.rest_api_exists(self, self.api_name)

    @unittest.skipIf(not prod_env, 'Development Auth API not under test.')
    def test_auth_saintsxctf_com_api_deployment_exists(self) -> None:
        """
        Test if a deployment exists for the auth.saintsxctf.com API Gateway REST API.
        """
        APIGateway.deployment_exists(self, self.api_name)

    @unittest.skipIf(not prod_env, 'Development Auth API not under test.')
    def test_auth_saintsxctf_com_api_stage_exists(self) -> None:
        """
        Test if a stage (named reference to a deployment) exists for the auth.saintsxctf.com API Gateway REST API.
        """
        if self.prod_env:
            stage_name = 'production'
        else:
            stage_name = 'development'

        APIGateway.stage_exists(self, self.api_name, stage_name)

    @unittest.skipIf(not prod_env, 'Development Auth API not under test.')
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

    @unittest.skipIf(not prod_env, 'Development Auth API not under test.')
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

    @unittest.skipIf(not prod_env, 'Development Auth API not under test.')
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

    @unittest.skipIf(not prod_env, 'Development Auth API not under test.')
    def test_auth_saintsxctf_com_api_has_expected_paths(self) -> None:
        """
        Test that the expected paths exist in 'auth.saintsxctf.com.'.
        """
        expected_paths = ['/', '/authenticate', '/token']
        APIGateway.api_has_expected_paths(self, self.api_name, expected_paths)

    @unittest.skipIf(not prod_env, 'Development Auth API not under test.')
    def test_auth_saintsxctf_com_api_token_endpoint(self) -> None:
        """
        Test that the '/token' endpoint exists in 'auth.saintsxctf.com.' as expected.
        """
        if self.prod_env:
            lambda_function_name = 'SaintsXCTFTokenPROD'
            validator_name = 'auth-token-request-body-production'
        else:
            lambda_function_name = 'SaintsXCTFTokenDEV'
            validator_name = 'auth-token-request-body-development'

        APIGateway.api_endpoint_as_expected(
            test_case=self,
            api_name=self.api_name,
            path='/token',
            validator_name=validator_name,
            lambda_function_name=lambda_function_name,
            validate_request_body=True,
            validate_request_parameters=False
        )

    @unittest.skipIf(not prod_env, 'Development Auth API not under test.')
    def test_auth_saintsxctf_com_api_authenticate_endpoint(self) -> None:
        """
        Test that the '/authenticate' endpoint exists in 'auth.saintsxctf.com.' as expected.
        """
        if self.prod_env:
            lambda_function_name = 'SaintsXCTFAuthenticatePROD'
            validator_name = 'auth-authenticate-request-body-production'
        else:
            lambda_function_name = 'SaintsXCTFAuthenticateDEV'
            validator_name = 'auth-authenticate-request-body-development'

        APIGateway.api_endpoint_as_expected(
            test_case=self,
            api_name=self.api_name,
            path='/authenticate',
            validator_name=validator_name,
            lambda_function_name=lambda_function_name,
            validate_request_body=True,
            validate_request_parameters=False
        )

    def test_rotate_secret_lambda_role_exists(self) -> None:
        """
        Test that the rotate-secret-lambda-role IAM Role exists.
        """
        self.assertTrue(IAM.iam_role_exists(role_name=f'rotate-secret-lambda-role-{self.env}'))

    def test_rotate_secret_lambda_policy_attached(self) -> None:
        """
        Test that the rotate-secret-lambda-policy is attached to the rotate-secret-lambda-role
        """
        self.assertTrue(IAM.iam_policy_attached_to_role(
            role_name=f'rotate-secret-lambda-role-{self.env}',
            policy_name=f'rotate-secret-lambda-policy-{self.env}'
        ))

    def test_token_lambda_role_exists(self) -> None:
        """
        Test that the token-lambda-role IAM Role exists.
        """
        self.assertTrue(IAM.iam_role_exists(role_name=f'token-lambda-role-{self.env}'))

    def test_token_lambda_policy_attached(self) -> None:
        """
        Test that the token-lambda-policy is attached to the token-lambda-role
        """
        self.assertTrue(IAM.iam_policy_attached_to_role(
            role_name=f'token-lambda-role-{self.env}',
            policy_name=f'token-lambda-policy-{self.env}'
        ))

    def test_authorizer_lambda_role_exists(self) -> None:
        """
        Test that the authorizer-lambda-role IAM Role exists.
        """
        self.assertTrue(IAM.iam_role_exists(role_name=f'authorizer-lambda-role-{self.env}'))

    def test_authorizer_lambda_policy_attached(self) -> None:
        """
        Test that the authorizer-lambda-policy is attached to the authorizer-lambda-role
        """
        self.assertTrue(IAM.iam_policy_attached_to_role(
            role_name=f'authorizer-lambda-role-{self.env}',
            policy_name=f'authorizer-lambda-policy-{self.env}'
        ))

    @unittest.skipIf(not prod_env, 'Development authorizer AWS Lambda function not under test.')
    def test_authorizer_lambda_function_exists(self) -> None:
        """
        Test that a SaintsXCTF auth authorizer AWS Lambda function exists.
        :return: True if the function exists, False otherwise
        """
        if self.prod_env:
            function_name = 'SaintsXCTFAuthorizerPROD'
            env = 'prod'
        else:
            function_name = 'SaintsXCTFAuthorizerDEV'
            env = 'dev'

        Lambda.lambda_function_as_expected(
            test_case=self,
            function_name=function_name,
            handler='function.lambda_handler',
            runtime='python3.8',
            env_vars={"ENV": env}
        )

    @unittest.skipIf(not prod_env, 'Development authorizer AWS Lambda function not under test.')
    def test_authorizer_lambda_function_has_iam_role(self) -> None:
        """
        Test that a SaintsXCTF auth authorizer AWS Lambda function has the proper IAM role.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFAuthorizerPROD'
        else:
            function_name = 'SaintsXCTFAuthorizerDEV'

        self.assertTrue(Lambda.lambda_function_has_iam_role(
            function_name=function_name,
            role_name='authorizer-lambda-role'
        ))

    @unittest.skipIf(not prod_env, 'Development authorizer AWS Lambda function not under test.')
    def test_authorizer_lambda_function_has_cloudwatch_log_group(self) -> None:
        """
        Test that a Cloudwatch log group exists for the SaintsXCTF auth authorizer AWS Lambda function.
        """
        if self.prod_env:
            log_group_name = '/aws/lambda/SaintsXCTFAuthorizerPROD'
        else:
            log_group_name = '/aws/lambda/SaintsXCTFAuthorizerDEV'

        CloudWatchLogs.cloudwatch_log_group_exists(test_case=self, log_group_name=log_group_name, retention_days=7)

    @unittest.skipIf(not prod_env, 'Development rotate AWS Lambda function not under test.')
    def test_rotate_lambda_function_exists(self) -> None:
        """
        Test that a SaintsXCTF auth rotate AWS Lambda function exists.
        :return: True if the function exists, False otherwise
        """
        if self.prod_env:
            function_name = 'SaintsXCTFRotatePROD'
        else:
            function_name = 'SaintsXCTFRotateDEV'

        Lambda.lambda_function_as_expected(
            test_case=self,
            function_name=function_name,
            handler='function.lambda_handler',
            runtime='python3.8',
            env_vars=None
        )

    @unittest.skipIf(not prod_env, 'Development rotate AWS Lambda function not under test.')
    def test_rotate_lambda_function_has_iam_role(self) -> None:
        """
        Test that a SaintsXCTF auth rotate AWS Lambda function has the proper IAM role.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFRotatePROD'
        else:
            function_name = 'SaintsXCTFRotateDEV'

        self.assertTrue(Lambda.lambda_function_has_iam_role(
            function_name=function_name,
            role_name='rotate-secret-lambda-role'
        ))

    @unittest.skipIf(not prod_env, 'Development rotate AWS Lambda function not under test.')
    def test_rotate_lambda_function_has_cloudwatch_log_group(self) -> None:
        """
        Test that a Cloudwatch log group exists for the SaintsXCTF auth rotate AWS Lambda function.
        """
        if self.prod_env:
            log_group_name = '/aws/lambda/SaintsXCTFRotatePROD'
        else:
            log_group_name = '/aws/lambda/SaintsXCTFRotateDEV'

        CloudWatchLogs.cloudwatch_log_group_exists(test_case=self, log_group_name=log_group_name, retention_days=7)

    @unittest.skipIf(not prod_env, 'Development authenticate AWS Lambda function not under test.')
    def test_authenticate_lambda_function_exists(self) -> None:
        """
        Test that a SaintsXCTF auth authenticate AWS Lambda function exists.
        :return: True if the function exists, False otherwise
        """
        if self.prod_env:
            function_name = 'SaintsXCTFAuthenticatePROD'
            env = 'prod'
        else:
            function_name = 'SaintsXCTFAuthenticateDEV'
            env = 'dev'

        Lambda.lambda_function_as_expected(
            test_case=self,
            function_name=function_name,
            handler='function.lambda_handler',
            runtime='python3.8',
            memory_size=512,
            env_vars={"ENV": env}
        )

    @unittest.skipIf(not prod_env, 'Development authenticate AWS Lambda function not under test.')
    def test_authenticate_lambda_function_has_iam_role(self) -> None:
        """
        Test that a SaintsXCTF auth authenticate AWS Lambda function has the proper IAM role.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFAuthenticatePROD'
        else:
            function_name = 'SaintsXCTFAuthenticateDEV'

        self.assertTrue(Lambda.lambda_function_has_iam_role(
            function_name=function_name,
            role_name='authorizer-lambda-role'
        ))

    @unittest.skipIf(not prod_env, 'Development authenticate AWS Lambda function not under test.')
    def test_authenticate_lambda_function_has_cloudwatch_log_group(self) -> None:
        """
        Test that a Cloudwatch log group exists for the SaintsXCTF auth authenticate AWS Lambda function.
        """
        if self.prod_env:
            log_group_name = '/aws/lambda/SaintsXCTFAuthenticatePROD'
        else:
            log_group_name = '/aws/lambda/SaintsXCTFAuthenticateDEV'

        CloudWatchLogs.cloudwatch_log_group_exists(test_case=self, log_group_name=log_group_name, retention_days=7)

    @unittest.skipIf(not prod_env, 'Development token AWS Lambda function not under test.')
    def test_authenticate_lambda_function_provisioned_concurrency_config(self) -> None:
        if self.prod_env:
            function_name = 'SaintsXCTFAuthenticatePROD'
            qualifier = 'SaintsXCTFAuthenticatePRODCurrent'
        else:
            function_name = 'SaintsXCTFAuthenticateDEV'
            qualifier = 'SaintsXCTFAuthenticateDEVCurrent'

        prov_concurrency_config = self.lambda_.get_provisioned_concurrency_config(
            FunctionName=function_name,
            Qualifier=qualifier
        )

        self.assertEqual('READY', prov_concurrency_config.get('Status'))
        self.assertEqual(1, prov_concurrency_config.get('RequestedProvisionedConcurrentExecutions'))
        self.assertEqual(1, prov_concurrency_config.get('AvailableProvisionedConcurrentExecutions'))
        self.assertEqual(1, prov_concurrency_config.get('AllocatedProvisionedConcurrentExecutions'))

    @unittest.skipIf(not prod_env, 'Development token AWS Lambda function not under test.')
    def test_token_lambda_function_exists(self) -> None:
        """
        Test that a SaintsXCTF auth token AWS Lambda function exists.
        :return: True if the function exists, False otherwise
        """
        if self.prod_env:
            function_name = 'SaintsXCTFTokenPROD'
            env = 'prod'
        else:
            function_name = 'SaintsXCTFTokenDEV'
            env = 'dev'

        Lambda.lambda_function_as_expected(
            test_case=self,
            function_name=function_name,
            handler='function.lambda_handler',
            runtime='python3.8',
            memory_size=1792,
            env_vars={"ENV": env}
        )

    @unittest.skipIf(not prod_env, 'Development token AWS Lambda function not under test.')
    def test_token_lambda_function_has_iam_role(self) -> None:
        """
        Test that a SaintsXCTF auth token AWS Lambda function has the proper IAM role.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFTokenPROD'
        else:
            function_name = 'SaintsXCTFTokenDEV'

        self.assertTrue(Lambda.lambda_function_has_iam_role(
            function_name=function_name,
            role_name='token-lambda-role'
        ))

    @unittest.skipIf(not prod_env, 'Development token AWS Lambda function not under test.')
    def test_token_lambda_function_has_cloudwatch_log_group(self) -> None:
        """
        Test that a Cloudwatch log group exists for the SaintsXCTF auth token AWS Lambda function.
        """
        if self.prod_env:
            log_group_name = '/aws/lambda/SaintsXCTFTokenPROD'
        else:
            log_group_name = '/aws/lambda/SaintsXCTFTokenDEV'

        CloudWatchLogs.cloudwatch_log_group_exists(test_case=self, log_group_name=log_group_name, retention_days=7)

    @unittest.skipIf(not prod_env, 'Development token AWS Lambda function not under test.')
    def test_token_lambda_function_provisioned_concurrency_config(self) -> None:
        if self.prod_env:
            function_name = 'SaintsXCTFTokenPROD'
            qualifier = 'SaintsXCTFTokenPRODCurrent'
        else:
            function_name = 'SaintsXCTFTokenDEV'
            qualifier = 'SaintsXCTFTokenDEVCurrent'

        prov_concurrency_config = self.lambda_.get_provisioned_concurrency_config(
            FunctionName=function_name,
            Qualifier=qualifier
        )

        self.assertEqual('READY', prov_concurrency_config.get('Status'))
        self.assertEqual(1, prov_concurrency_config.get('RequestedProvisionedConcurrentExecutions'))
        self.assertEqual(1, prov_concurrency_config.get('AvailableProvisionedConcurrentExecutions'))
        self.assertEqual(1, prov_concurrency_config.get('AllocatedProvisionedConcurrentExecutions'))

    @unittest.skipIf(not prod_env, 'Development token AWS Lambda function not under test.')
    def test_token_lambda_function_in_vpc(self) -> None:
        """
        Test that a SaintsXCTF auth token AWS Lambda function exists in the proper VPC.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFTokenPROD'
        else:
            function_name = 'SaintsXCTFTokenDEV'

        lambda_function = self.lambda_.get_function(FunctionName=function_name)
        lambda_function_vpc_id = lambda_function.get('Configuration').get('VpcConfig').get('VpcId')

        vpc = VPC.get_vpc('application-vpc')
        vpc_id = vpc.get('VpcId')

        self.assertTrue(vpc_id == lambda_function_vpc_id)

    @unittest.skipIf(not prod_env, 'Development token AWS Lambda function not under test.')
    def test_token_lambda_function_in_subnets(self) -> None:
        """
        Test that a SaintsXCTF auth token AWS Lambda function exists in the proper subnets.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFTokenPROD'
        else:
            function_name = 'SaintsXCTFTokenDEV'

        self.assertTrue(Lambda.lambda_function_in_subnets(
            function_name=function_name,
            subnets=['saints-xctf-com-lisag-public-subnet', 'saints-xctf-com-megank-public-subnet']
        ))
