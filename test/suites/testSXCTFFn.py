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

from aws_test_functions.APIGateway import APIGateway
from aws_test_functions.IAM import IAM
from aws_test_functions.Route53 import Route53
from aws_test_functions.Lambda import Lambda
from aws_test_functions.CloudWatchLogs import CloudWatchLogs

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
        self.aws_lambda: LambdaClient = boto3.client('lambda', region_name='us-east-1')
        self.prod_env = prod_env

        if self.prod_env:
            self.domain_name = 'fn.saintsxctf.com'
            self.api_name = 'saints-xctf-com-fn'
        else:
            self.domain_name = 'dev.fn.saintsxctf.com'
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
        domain = self.apigateway.get_domain_name(domainName=self.domain_name)
        self.assertEqual('AVAILABLE', domain.get('domainNameStatus'))

    @unittest.skipIf(prod_env, 'Production Function API not running.')
    def test_fn_saintsxctf_com_api_base_path_mapping_empty(self) -> None:
        """
        Test that an empty string is configured for the base path mapping of the fn.saintsxctf.com REST API.
        """
        base_path_mappings = self.apigateway.get_base_path_mappings(domainName=self.domain_name)
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

    @unittest.skipIf(prod_env, 'Production Function API not running.')
    def test_fn_saintsxctf_com_api_route53_record_exists(self) -> None:
        """
        Determine if an 'A' record exists for 'fn.saintsxctf.com.' in Route53
        """
        try:
            a_record = Route53.get_record(f'saintsxctf.com.', f'{self.domain_name}.', 'A')
        except IndexError:
            self.assertTrue(False)
            return

        print(a_record)
        self.assertTrue(a_record.get('Name') == f'{self.domain_name}.' and a_record.get('Type') == 'A')

    @unittest.skipIf(prod_env, 'Production Function API not running.')
    def test_fn_saintsxctf_com_api_has_expected_paths(self) -> None:
        """
        Test that the expected paths exist in 'fn.saintsxctf.com.'.
        """
        expected_paths = [
            '/', '/email', '/email/forgot-password', '/email/welcome', '/uasset', '/uasset/group', '/uasset/user'
        ]
        APIGateway.api_has_expected_paths(self, self.api_name, expected_paths)

    @unittest.skipIf(prod_env, 'Production Function API not running.')
    def test_fn_saintsxctf_com_api_email_forgot_password_endpoint(self) -> None:
        """
        Test that the '/email/forgot-password' endpoint exists in 'fn.saintsxctf.com.' as expected.
        """
        if self.prod_env:
            lambda_function_name = 'SaintsXCTFForgotPasswordEmailPROD'
            validator_name = 'email-forgot-password-request-body-production'
        else:
            lambda_function_name = 'SaintsXCTFForgotPasswordEmailDEV'
            validator_name = 'email-forgot-password-request-body-development'

        APIGateway.api_endpoint_as_expected(
            test_case=self,
            api_name=self.api_name,
            path='/email/forgot-password',
            validator_name=validator_name,
            lambda_function_name=lambda_function_name,
            validate_request_body=True,
            validate_request_parameters=False
        )

    @unittest.skipIf(prod_env, 'Production Function API not running.')
    def test_fn_saintsxctf_com_api_uasset_user_endpoint(self) -> None:
        """
        Test that the '/uasset/user' endpoint exists in 'fn.saintsxctf.com.' as expected.
        """
        if self.prod_env:
            lambda_function_name = 'SaintsXCTFUassetUserPROD'
            validator_name = 'uasset-user-request-body-production'
        else:
            lambda_function_name = 'SaintsXCTFUassetUserDEV'
            validator_name = 'uasset-user-request-body-development'

        APIGateway.api_endpoint_as_expected(
            test_case=self,
            api_name=self.api_name,
            path='/uasset/user',
            validator_name=validator_name,
            lambda_function_name=lambda_function_name,
            validate_request_body=True,
            validate_request_parameters=False
        )

    @unittest.skipIf(prod_env, 'Production forgot password AWS Lambda function not running.')
    def test_forgot_password_email_lambda_function_exists(self) -> None:
        """
        Test that an AWS Lambda function exists for sending emails when a user forgets their SaintsXCTF password.
        :return: True if the function exists, False otherwise
        """
        if self.prod_env:
            function_name = 'SaintsXCTFForgotPasswordEmailPROD'
            prefix = ''
        else:
            function_name = 'SaintsXCTFForgotPasswordEmailDEV'
            prefix = 'dev.'

        Lambda.lambda_function_as_expected(
            test_case=self,
            function_name=function_name,
            handler='sendEmailAWS.sendForgotPasswordEmail',
            runtime='nodejs12.x',
            env_vars={"PREFIX": prefix}
        )

    def test_email_lambda_role_exists(self) -> None:
        """
        Test that the email-lambda-role IAM Role exists.
        """
        self.assertTrue(IAM.iam_role_exists(role_name='email-lambda-role'))

    def test_email_lambda_policy_attached(self) -> None:
        """
        Test that the email-lambda-policy is attached to the email-lambda-role
        """
        self.assertTrue(IAM.iam_policy_attached_to_role(
            role_name='email-lambda-role',
            policy_name='email-lambda-policy'
        ))

    @unittest.skipIf(prod_env, 'Production forgot password email AWS Lambda function not running.')
    def test_forgot_password_email_lambda_function_has_iam_role(self) -> None:
        """
        Test that an AWS Lambda function for sending emails when a user forgets their SaintsXCTF password has the
        proper IAM role.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFForgotPasswordEmailPROD'
        else:
            function_name = 'SaintsXCTFForgotPasswordEmailDEV'

        self.assertTrue(Lambda.lambda_function_has_iam_role(
            function_name=function_name,
            role_name='email-lambda-role'
        ))

    @unittest.skipIf(prod_env, 'Production forgot password email AWS Lambda function not running.')
    def test_forgot_password_email_lambda_function_has_cloudwatch_log_group(self) -> None:
        """
        Test that a Cloudwatch log group exists for the forgot password email AWS Lambda function.
        """
        if self.prod_env:
            log_group_name = '/aws/lambda/SaintsXCTFForgotPasswordEmailPROD'
        else:
            log_group_name = '/aws/lambda/SaintsXCTFForgotPasswordEmailDEV'

        CloudWatchLogs.cloudwatch_log_group_exists(test_case=self, log_group_name=log_group_name, retention_days=7)

    @unittest.skipIf(prod_env, 'Production uasset user AWS Lambda function not running.')
    def test_uasset_user_lambda_function_exists(self) -> None:
        """
        Test that an AWS Lambda function exists for uploading a user's profile picture to the uasset.saintsxctf.com
        S3 bucket.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFUassetUserPROD'
            env = 'prod'
        else:
            function_name = 'SaintsXCTFUassetUserDEV'
            env = 'dev'

        Lambda.lambda_function_as_expected(
            test_case=self,
            function_name=function_name,
            handler='index.upload',
            runtime='nodejs12.x',
            env_vars={"ENV": env}
        )

    def test_uasset_lambda_role_exists(self) -> None:
        """
        Test that the uasset-lambda-role IAM Role exists.
        """
        self.assertTrue(IAM.iam_role_exists(role_name='uasset-lambda-role'))

    def test_uasset_lambda_policy_attached(self) -> None:
        """
        Test that the uasset-lambda-policy is attached to the uasset-lambda-role
        """
        self.assertTrue(IAM.iam_policy_attached_to_role(
            role_name='uasset-lambda-role',
            policy_name='uasset-lambda-policy'
        ))

    @unittest.skipIf(prod_env, 'Production uasset user AWS Lambda function not running.')
    def test_uasset_user_lambda_function_has_iam_role(self) -> None:
        """
        Test that an AWS Lambda function for uploading a user's profile picture to the uasset.saintsxctf.com
        S3 bucket has the proper IAM role.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFUassetUserPROD'
        else:
            function_name = 'SaintsXCTFUassetUserDEV'

        self.assertTrue(Lambda.lambda_function_has_iam_role(
            function_name=function_name,
            role_name='uasset-lambda-role'
        ))

    @unittest.skipIf(prod_env, 'Production uasset user AWS Lambda function not running.')
    def test_uasset_user_lambda_function_has_cloudwatch_log_group(self) -> None:
        """
        Test that a Cloudwatch log group exists for the uasset user AWS Lambda function.
        """
        if self.prod_env:
            log_group_name = '/aws/lambda/SaintsXCTFUassetUserPROD'
        else:
            log_group_name = '/aws/lambda/SaintsXCTFUassetUserDEV'

        CloudWatchLogs.cloudwatch_log_group_exists(test_case=self, log_group_name=log_group_name, retention_days=7)
