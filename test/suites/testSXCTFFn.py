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
            self.env = 'prod'
        else:
            self.domain_name = 'dev.fn.saintsxctf.com'
            self.api_name = 'saints-xctf-com-fn-dev'
            self.env = 'dev'

    @unittest.skipIf(not prod_env, 'Development Function API not under test.')
    def test_fn_saintsxctf_com_api_exists(self) -> None:
        """
        Test if the fn.saintsxctf.com API Gateway REST API exists
        """
        APIGateway.rest_api_exists(self, self.api_name)

    @unittest.skipIf(not prod_env, 'Development Function API not under test.')
    def test_fn_saintsxctf_com_api_deployment_exists(self) -> None:
        """
        Test if a deployment exists for the fn.saintsxctf.com API Gateway REST API.
        """
        APIGateway.deployment_exists(self, self.api_name)

    @unittest.skipIf(not prod_env, 'Development Function API not under test.')
    def test_fn_saintsxctf_com_api_stage_exists(self) -> None:
        """
        Test if a stage (named reference to a deployment) exists for the fn.saintsxctf.com API Gateway REST API.
        """
        if self.prod_env:
            stage_name = 'production'
        else:
            stage_name = 'development'

        APIGateway.stage_exists(self, self.api_name, stage_name)

    @unittest.skipIf(not prod_env, 'Development Function API not under test.')
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
            authorizer_name = 'function:SaintsXCTFAuthorizerPROD/invocations'
        else:
            authorizer_name = 'function:SaintsXCTFAuthorizerDEV/invocations'

        self.assertTrue(authorizer_name in authorizer.get('authorizerUri'))

    @unittest.skipIf(not prod_env, 'Development Function API not under test.')
    def test_fn_saintsxctf_com_api_domain_name_exists(self) -> None:
        """
        Test that a domain name is configured for the fn.saintsxctf.com REST API.
        """
        domain = self.apigateway.get_domain_name(domainName=self.domain_name)
        self.assertEqual('AVAILABLE', domain.get('domainNameStatus'))

    @unittest.skipIf(not prod_env, 'Development Function API not under test.')
    def test_fn_saintsxctf_com_api_base_path_mapping_empty(self) -> None:
        """
        Test that an empty string is configured for the base path mapping of the fn.saintsxctf.com REST API.
        """
        base_path_mappings = self.apigateway.get_base_path_mappings(domainName=self.domain_name)
        base_path_mapping_list: List[dict] = base_path_mappings.get('items')
        self.assertEqual(1, len(base_path_mapping_list))

        base_path_mapping = base_path_mapping_list[0]
        self.assertEqual('(none)', base_path_mapping.get('basePath'))

    @unittest.skipIf(not prod_env, 'Development Function API not under test.')
    def test_api_gateway_auth_role_exists(self) -> None:
        """
        Test that the api-gateway-auth-role IAM Role exists.
        """
        self.assertTrue(IAM.iam_role_exists(role_name=f'api-gateway-auth-role-{self.env}'))

    @unittest.skipIf(not prod_env, 'Development Function API not under test.')
    def test_api_gateway_auth_policy_attached(self) -> None:
        """
        Test that the api-gateway-auth-policy is attached to the api-gateway-auth-role
        """
        self.assertTrue(IAM.iam_policy_attached_to_role(
            role_name=f'api-gateway-auth-role-{self.env}',
            policy_name=f'api-gateway-auth-policy-{self.env}'
        ))

    @unittest.skipIf(not prod_env, 'Development Function API not under test.')
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

    @unittest.skipIf(not prod_env, 'Development Function API not under test.')
    def test_fn_saintsxctf_com_api_has_expected_paths(self) -> None:
        """
        Test that the expected paths exist in 'fn.saintsxctf.com.'.
        """
        expected_paths = [
            '/',
            '/email',
            '/email/activation-code',
            '/email/forgot-password',
            '/email/report',
            '/email/welcome',
            '/uasset',
            '/uasset/group',
            '/uasset/signed-url',
            '/uasset/signed-url/group',
            '/uasset/signed-url/user',
            '/uasset/user'
        ]
        APIGateway.api_has_expected_paths(self, self.api_name, expected_paths)

    @unittest.skipIf(not prod_env, 'Development Function API not under test.')
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

    @unittest.skipIf(not prod_env, 'Development Function API not under test.')
    def test_fn_saintsxctf_com_api_email_activation_code_endpoint(self) -> None:
        """
        Test that the '/email/activation-code' endpoint exists in 'fn.saintsxctf.com.' as expected.
        """
        if self.prod_env:
            lambda_function_name = 'SaintsXCTFSendActivationEmailPROD'
            validator_name = 'email-activation-code-request-body-production'
        else:
            lambda_function_name = 'SaintsXCTFSendActivationEmailDEV'
            validator_name = 'email-activation-code-request-body-development'

        APIGateway.api_endpoint_as_expected(
            test_case=self,
            api_name=self.api_name,
            path='/email/activation-code',
            validator_name=validator_name,
            lambda_function_name=lambda_function_name,
            validate_request_body=True,
            validate_request_parameters=False,
            authorization_type='CUSTOM'
        )

    @unittest.skipIf(not prod_env, 'Development Function API not under test.')
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
            validate_request_parameters=False,
            authorization_type='CUSTOM'
        )

    @unittest.skipIf(not prod_env, 'Development Function API not under test.')
    def test_fn_saintsxctf_com_api_uasset_group_endpoint(self) -> None:
        """
        Test that the '/uasset/group' endpoint exists in 'fn.saintsxctf.com.' as expected.
        """
        if self.prod_env:
            lambda_function_name = 'SaintsXCTFUassetGroupPROD'
            validator_name = 'uasset-group-request-body-production'
        else:
            lambda_function_name = 'SaintsXCTFUassetGroupDEV'
            validator_name = 'uasset-group-request-body-development'

        APIGateway.api_endpoint_as_expected(
            test_case=self,
            api_name=self.api_name,
            path='/uasset/group',
            validator_name=validator_name,
            lambda_function_name=lambda_function_name,
            validate_request_body=True,
            validate_request_parameters=False,
            authorization_type='CUSTOM'
        )

    @unittest.skipIf(not prod_env, 'Development Function API not under test.')
    def test_fn_saintsxctf_com_api_uasset_signed_url_user_endpoint(self) -> None:
        """
        Test that the '/uasset/signed-url/user' endpoint exists in 'fn.saintsxctf.com.' as expected.
        """
        if self.prod_env:
            lambda_function_name = 'SaintsXCTFUassetSignedUrlUserPROD'
            validator_name = 'uasset-signed-url-user-request-body-production'
        else:
            lambda_function_name = 'SaintsXCTFUassetSignedUrlUserDEV'
            validator_name = 'uasset-signed-url-user-request-body-development'

        APIGateway.api_endpoint_as_expected(
            test_case=self,
            api_name=self.api_name,
            path='/uasset/signed-url/user',
            validator_name=validator_name,
            lambda_function_name=lambda_function_name,
            validate_request_body=True,
            validate_request_parameters=False,
            authorization_type='CUSTOM'
        )

    @unittest.skipIf(not prod_env, 'Development Function API not under test.')
    def test_fn_saintsxctf_com_api_uasset_signed_url_group_endpoint(self) -> None:
        """
        Test that the '/uasset/signed-url/group' endpoint exists in 'fn.saintsxctf.com.' as expected.
        """
        if self.prod_env:
            lambda_function_name = 'SaintsXCTFUassetSignedUrlGroupPROD'
            validator_name = 'uasset-signed-url-group-request-body-production'
        else:
            lambda_function_name = 'SaintsXCTFUassetSignedUrlGroupDEV'
            validator_name = 'uasset-signed-url-group-request-body-development'

        APIGateway.api_endpoint_as_expected(
            test_case=self,
            api_name=self.api_name,
            path='/uasset/signed-url/group',
            validator_name=validator_name,
            lambda_function_name=lambda_function_name,
            validate_request_body=True,
            validate_request_parameters=False,
            authorization_type='CUSTOM'
        )

    @unittest.skipIf(not prod_env, 'Development forgot password AWS Lambda function not under test.')
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

    @unittest.skipIf(not prod_env, 'Development email AWS Lambda functions not under test.')
    def test_email_lambda_role_exists(self) -> None:
        """
        Test that the email-lambda-role IAM Role exists.
        """
        self.assertTrue(IAM.iam_role_exists(role_name=f'email-lambda-role-{self.env}'))

    @unittest.skipIf(not prod_env, 'Development email AWS Lambda functions not under test.')
    def test_email_lambda_policy_attached(self) -> None:
        """
        Test that the email-lambda-policy is attached to the email-lambda-role
        """
        self.assertTrue(IAM.iam_policy_attached_to_role(
            role_name=f'email-lambda-role-{self.env}',
            policy_name=f'email-lambda-policy-{self.env}'
        ))

    @unittest.skipIf(not prod_env, 'Development forgot password email AWS Lambda function not under test.')
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

    @unittest.skipIf(not prod_env, 'Development forgot password email AWS Lambda function not under test.')
    def test_forgot_password_email_lambda_function_has_cloudwatch_log_group(self) -> None:
        """
        Test that a Cloudwatch log group exists for the forgot password email AWS Lambda function.
        """
        if self.prod_env:
            log_group_name = '/aws/lambda/SaintsXCTFForgotPasswordEmailPROD'
        else:
            log_group_name = '/aws/lambda/SaintsXCTFForgotPasswordEmailDEV'

        CloudWatchLogs.cloudwatch_log_group_exists(test_case=self, log_group_name=log_group_name, retention_days=7)

    @unittest.skipIf(not prod_env, 'Development activation code AWS Lambda function not under test.')
    def test_activation_code_email_lambda_function_exists(self) -> None:
        """
        Test that an AWS Lambda function exists for sending emails to new users with activation codes.
        :return: True if the function exists, False otherwise
        """
        if self.prod_env:
            function_name = 'SaintsXCTFActivationCodeEmailPROD'
            prefix = ''
        else:
            function_name = 'SaintsXCTFActivationCodeEmailDEV'
            prefix = 'dev.'

        Lambda.lambda_function_as_expected(
            test_case=self,
            function_name=function_name,
            handler='sendEmailAWS.sendActivationCodeEmail',
            runtime='nodejs12.x',
            env_vars={"PREFIX": prefix}
        )

    @unittest.skipIf(not prod_env, 'Development activation code email AWS Lambda function not under test.')
    def test_activation_code_email_lambda_function_has_iam_role(self) -> None:
        """
        Test that an AWS Lambda function for sending emails to new users with activation codes has the proper IAM role.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFActivationCodeEmailPROD'
        else:
            function_name = 'SaintsXCTFActivationCodeEmailDEV'

        self.assertTrue(Lambda.lambda_function_has_iam_role(
            function_name=function_name,
            role_name='email-lambda-role'
        ))

    @unittest.skipIf(not prod_env, 'Development activation code email AWS Lambda function not under test.')
    def test_activation_code_email_lambda_function_has_cloudwatch_log_group(self) -> None:
        """
        Test that a Cloudwatch log group exists for the activation code email AWS Lambda function.
        """
        if self.prod_env:
            log_group_name = '/aws/lambda/SaintsXCTFActivationCodeEmailPROD'
        else:
            log_group_name = '/aws/lambda/SaintsXCTFActivationCodeEmailDEV'

        CloudWatchLogs.cloudwatch_log_group_exists(test_case=self, log_group_name=log_group_name, retention_days=7)

    @unittest.skipIf(not prod_env, 'Development report email AWS Lambda function not under test.')
    def test_report_email_lambda_function_exists(self) -> None:
        """
        Test that an AWS Lambda function exists for sending an email to me when a user writes a report.
        :return: True if the function exists, False otherwise
        """
        if self.prod_env:
            function_name = 'SaintsXCTFReportEmailPROD'
            prefix = ''
        else:
            function_name = 'SaintsXCTFReportEmailDEV'
            prefix = 'dev.'

        Lambda.lambda_function_as_expected(
            test_case=self,
            function_name=function_name,
            handler='sendEmailAWS.sendReportEmail',
            runtime='nodejs12.x',
            env_vars={"PREFIX": prefix}
        )

    @unittest.skipIf(not prod_env, 'Development report email AWS Lambda function not under test.')
    def test_report_email_lambda_function_has_iam_role(self) -> None:
        """
        Test that an AWS Lambda function for sending an email to me when a user writes a report has the proper IAM role.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFReportEmailPROD'
        else:
            function_name = 'SaintsXCTFReportEmailDEV'

        self.assertTrue(Lambda.lambda_function_has_iam_role(
            function_name=function_name,
            role_name='email-lambda-role'
        ))

    @unittest.skipIf(not prod_env, 'Development report email AWS Lambda function not under test.')
    def test_report_email_lambda_function_has_cloudwatch_log_group(self) -> None:
        """
        Test that a Cloudwatch log group exists for the report email AWS Lambda function.
        """
        if self.prod_env:
            log_group_name = '/aws/lambda/SaintsXCTFReportEmailPROD'
        else:
            log_group_name = '/aws/lambda/SaintsXCTFReportEmailDEV'

        CloudWatchLogs.cloudwatch_log_group_exists(test_case=self, log_group_name=log_group_name, retention_days=7)

    @unittest.skipIf(not prod_env, 'Development welcome email AWS Lambda function not under test.')
    def test_welcome_email_lambda_function_exists(self) -> None:
        """
        Test that an AWS Lambda function exists for sending a welcome email to a new user.
        :return: True if the function exists, False otherwise
        """
        if self.prod_env:
            function_name = 'SaintsXCTFWelcomeEmailPROD'
            prefix = ''
        else:
            function_name = 'SaintsXCTFWelcomeEmailDEV'
            prefix = 'dev.'

        Lambda.lambda_function_as_expected(
            test_case=self,
            function_name=function_name,
            handler='sendEmailAWS.sendWelcomeEmail',
            runtime='nodejs12.x',
            env_vars={"PREFIX": prefix}
        )

    @unittest.skipIf(not prod_env, 'Development welcome email AWS Lambda function not under test.')
    def test_welcome_email_lambda_function_has_iam_role(self) -> None:
        """
        Test that an AWS Lambda function for sending a welcome email to a new user has the proper IAM role.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFWelcomeEmailPROD'
        else:
            function_name = 'SaintsXCTFWelcomeEmailDEV'

        self.assertTrue(Lambda.lambda_function_has_iam_role(
            function_name=function_name,
            role_name='email-lambda-role'
        ))

    @unittest.skipIf(not prod_env, 'Development welcome email AWS Lambda function not under test.')
    def test_welcome_email_lambda_function_has_cloudwatch_log_group(self) -> None:
        """
        Test that a Cloudwatch log group exists for the welcome email AWS Lambda function.
        """
        if self.prod_env:
            log_group_name = '/aws/lambda/SaintsXCTFWelcomeEmailPROD'
        else:
            log_group_name = '/aws/lambda/SaintsXCTFWelcomeEmailDEV'

        CloudWatchLogs.cloudwatch_log_group_exists(test_case=self, log_group_name=log_group_name, retention_days=7)

    @unittest.skipIf(not prod_env, 'Development uasset user AWS Lambda function not under test.')
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
            handler='index.handler',
            runtime='nodejs12.x',
            env_vars={"ENV": env}
        )

    @unittest.skipIf(not prod_env, 'Development uasset user AWS Lambda function not under test.')
    def test_uasset_user_lambda_function_uses_layers(self) -> None:
        """
        Test that the AWS Lambda function for uploading a user's profile picture to the uasset.saintsxctf.com S3 bucket
        has a single Lambda layer with the name 'upload-picture-layer'.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFUassetUserPROD'
        else:
            function_name = 'SaintsXCTFUassetUserDEV'

        lambda_function_response = self.aws_lambda.get_function(FunctionName=function_name)
        lambda_function_layers: List[dict] = lambda_function_response.get('Configuration').get('Layers')
        self.assertEqual(1, len(lambda_function_layers))

        layers_response: dict = self.aws_lambda.list_layers(CompatibleRuntime='nodejs')
        layers: List[dict] = layers_response.get('Layers')
        matching_layers = [layer for layer in layers if layer.get('LayerName') == 'upload-picture-layer']
        self.assertEqual(1, len(matching_layers))

        layer_arn: str = matching_layers[0].get('LayerArn')
        self.assertTrue(layer_arn in lambda_function_layers[0].get('Arn'))

    @unittest.skipIf(not prod_env, 'Development uasset AWS Lambda functions not under test.')
    def test_uasset_lambda_role_exists(self) -> None:
        """
        Test that the uasset-lambda-role IAM Role exists.
        """
        self.assertTrue(IAM.iam_role_exists(role_name=f'uasset-lambda-role-{self.env}'))

    @unittest.skipIf(not prod_env, 'Development uasset AWS Lambda functions not under test.')
    def test_uasset_lambda_policy_attached(self) -> None:
        """
        Test that the uasset-lambda-policy is attached to the uasset-lambda-role
        """
        self.assertTrue(IAM.iam_policy_attached_to_role(
            role_name=f'uasset-lambda-role-{self.env}',
            policy_name=f'uasset-lambda-policy-{self.env}'
        ))

    @unittest.skipIf(not prod_env, 'Development uasset user AWS Lambda function not under test.')
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

    @unittest.skipIf(not prod_env, 'Development uasset user AWS Lambda function not under test.')
    def test_uasset_user_lambda_function_has_cloudwatch_log_group(self) -> None:
        """
        Test that a Cloudwatch log group exists for the uasset user AWS Lambda function.
        """
        if self.prod_env:
            log_group_name = '/aws/lambda/SaintsXCTFUassetUserPROD'
        else:
            log_group_name = '/aws/lambda/SaintsXCTFUassetUserDEV'

        CloudWatchLogs.cloudwatch_log_group_exists(test_case=self, log_group_name=log_group_name, retention_days=7)

    @unittest.skipIf(not prod_env, 'Development uasset group AWS Lambda function not under test.')
    def test_uasset_group_lambda_function_exists(self) -> None:
        """
        Test that an AWS Lambda function exists for uploading a group's picture to the uasset.saintsxctf.com S3 bucket.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFUassetGroupPROD'
            env = 'prod'
        else:
            function_name = 'SaintsXCTFUassetGroupDEV'
            env = 'dev'

        Lambda.lambda_function_as_expected(
            test_case=self,
            function_name=function_name,
            handler='index.handler',
            runtime='nodejs12.x',
            env_vars={"ENV": env}
        )

    @unittest.skipIf(not prod_env, 'Development uasset group AWS Lambda function not under test.')
    def test_uasset_group_lambda_function_uses_layers(self) -> None:
        """
        Test that the AWS Lambda function for uploading a group's picture to the uasset.saintsxctf.com S3 bucket has a
        single Lambda layer with the name 'upload-picture-layer'.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFUassetGroupPROD'
        else:
            function_name = 'SaintsXCTFUassetGroupDEV'

        lambda_function_response = self.aws_lambda.get_function(FunctionName=function_name)
        lambda_function_layers: List[dict] = lambda_function_response.get('Configuration').get('Layers')
        self.assertEqual(1, len(lambda_function_layers))

        layers_response: dict = self.aws_lambda.list_layers(CompatibleRuntime='nodejs')
        layers: List[dict] = layers_response.get('Layers')
        matching_layers = [layer for layer in layers if layer.get('LayerName') == 'upload-picture-layer']
        self.assertEqual(1, len(matching_layers))

        layer_arn: str = matching_layers[0].get('LayerArn')
        self.assertTrue(layer_arn in lambda_function_layers[0].get('Arn'))

    @unittest.skipIf(not prod_env, 'Development uasset group AWS Lambda function not under test.')
    def test_uasset_group_lambda_function_has_iam_role(self) -> None:
        """
        Test that an AWS Lambda function for uploading a group's picture to the uasset.saintsxctf.com S3 bucket has the
        proper IAM role.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFUassetGroupPROD'
        else:
            function_name = 'SaintsXCTFUassetGroupDEV'

        self.assertTrue(Lambda.lambda_function_has_iam_role(
            function_name=function_name,
            role_name='uasset-lambda-role'
        ))

    @unittest.skipIf(not prod_env, 'Development uasset group AWS Lambda function not under test.')
    def test_uasset_group_lambda_function_has_cloudwatch_log_group(self) -> None:
        """
        Test that a Cloudwatch log group exists for the uasset group AWS Lambda function.
        """
        if self.prod_env:
            log_group_name = '/aws/lambda/SaintsXCTFUassetGroupPROD'
        else:
            log_group_name = '/aws/lambda/SaintsXCTFUassetGroupDEV'

        CloudWatchLogs.cloudwatch_log_group_exists(test_case=self, log_group_name=log_group_name, retention_days=7)

    @unittest.skipIf(not prod_env, 'Development uasset signed url user AWS Lambda function not under test.')
    def test_uasset_signed_url_user_lambda_function_exists(self) -> None:
        """
        Test that an AWS Lambda function exists for retrieving a signed URL used for uploading a user's profile picture
        to the uasset.saintsxctf.com S3 bucket.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFUassetSignedUrlUserPROD'
            env = 'prod'
        else:
            function_name = 'SaintsXCTFUassetSignedUrlUserDEV'
            env = 'dev'

        Lambda.lambda_function_as_expected(
            test_case=self,
            function_name=function_name,
            handler='index.handler',
            runtime='nodejs12.x',
            env_vars={"ENV": env}
        )

    @unittest.skipIf(not prod_env, 'Development uasset signed url user AWS Lambda function not under test.')
    def test_uasset_signed_url_user_lambda_function_uses_layers(self) -> None:
        """
        Test that the AWS Lambda function for retrieving a signed URL used for uploading a user's profile picture to
        the uasset.saintsxctf.com S3 bucket has no Lambda layers.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFUassetSignedUrlUserPROD'
        else:
            function_name = 'SaintsXCTFUassetSignedUrlUserDEV'

        lambda_function_response = self.aws_lambda.get_function(FunctionName=function_name)
        lambda_function_layers: List[dict] = lambda_function_response.get('Configuration').get('Layers')
        self.assertEqual(1, len(lambda_function_layers))

        layers_response: dict = self.aws_lambda.list_layers(CompatibleRuntime='nodejs')
        layers: List[dict] = layers_response.get('Layers')
        matching_layers = [layer for layer in layers if layer.get('LayerName') == 'upload-picture-layer']
        self.assertEqual(1, len(matching_layers))

        layer_arn: str = matching_layers[0].get('LayerArn')
        self.assertTrue(layer_arn in lambda_function_layers[0].get('Arn'))

    @unittest.skipIf(not prod_env, 'Development uasset signed url user AWS Lambda function not under test.')
    def test_uasset_signed_url_user_lambda_function_has_iam_role(self) -> None:
        """
        Test that an AWS Lambda function for retrieving a signed URL used for uploading a user's profile picture to the
        uasset.saintsxctf.com S3 bucket has the proper IAM role.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFUassetSignedUrlUserPROD'
        else:
            function_name = 'SaintsXCTFUassetSignedUrlUserDEV'

        self.assertTrue(Lambda.lambda_function_has_iam_role(
            function_name=function_name,
            role_name='uasset-lambda-role'
        ))

    @unittest.skipIf(not prod_env, 'Development uasset signed url user AWS Lambda function not under test.')
    def test_uasset_signed_url_user_lambda_function_has_cloudwatch_log_group(self) -> None:
        """
        Test that a Cloudwatch log group exists for the uasset user AWS Lambda function.
        """
        if self.prod_env:
            log_group_name = '/aws/lambda/SaintsXCTFUassetSignedUrlUserPROD'
        else:
            log_group_name = '/aws/lambda/SaintsXCTFUassetSignedUrlUserDEV'

        CloudWatchLogs.cloudwatch_log_group_exists(test_case=self, log_group_name=log_group_name, retention_days=7)

    @unittest.skipIf(not prod_env, 'Development uasset signed url group AWS Lambda function not under test.')
    def test_uasset_signed_url_group_lambda_function_exists(self) -> None:
        """
        Test that an AWS Lambda function exists for retrieving a signed URL used for uploading a group's picture to
        the uasset.saintsxctf.com S3 bucket.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFUassetSignedUrlGroupPROD'
            env = 'prod'
        else:
            function_name = 'SaintsXCTFUassetSignedUrlGroupDEV'
            env = 'dev'

        Lambda.lambda_function_as_expected(
            test_case=self,
            function_name=function_name,
            handler='index.handler',
            runtime='nodejs12.x',
            env_vars={"ENV": env}
        )

    @unittest.skipIf(not prod_env, 'Development uasset signed url group AWS Lambda function not under test.')
    def test_uasset_signed_url_group_lambda_function_uses_layers(self) -> None:
        """
        Test that the AWS Lambda function for retrieving a signed URL used for uploading a group's picture to the
        uasset.saintsxctf.com S3 bucket has no Lambda layers.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFUassetSignedUrlGroupPROD'
        else:
            function_name = 'SaintsXCTFUassetSignedUrlGroupDEV'

        lambda_function_response = self.aws_lambda.get_function(FunctionName=function_name)
        lambda_function_layers: List[dict] = lambda_function_response.get('Configuration').get('Layers')
        self.assertEqual(1, len(lambda_function_layers))

        layers_response: dict = self.aws_lambda.list_layers(CompatibleRuntime='nodejs')
        layers: List[dict] = layers_response.get('Layers')
        matching_layers = [layer for layer in layers if layer.get('LayerName') == 'upload-picture-layer']
        self.assertEqual(1, len(matching_layers))

        layer_arn: str = matching_layers[0].get('LayerArn')
        self.assertTrue(layer_arn in lambda_function_layers[0].get('Arn'))

    @unittest.skipIf(not prod_env, 'Development uasset signed url group AWS Lambda function not under test.')
    def test_uasset_signed_url_group_lambda_function_has_iam_role(self) -> None:
        """
        Test that an AWS Lambda function for retrieving a signed URL used for uploading a group's picture to the
        uasset.saintsxctf.com S3 bucket has the proper IAM role.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFUassetSignedUrlGroupPROD'
        else:
            function_name = 'SaintsXCTFUassetSignedUrlGroupDEV'

        self.assertTrue(Lambda.lambda_function_has_iam_role(
            function_name=function_name,
            role_name='uasset-lambda-role'
        ))

    @unittest.skipIf(not prod_env, 'Development uasset signed url group AWS Lambda function not under test.')
    def test_uasset_signed_url_group_lambda_function_has_cloudwatch_log_group(self) -> None:
        """
        Test that a Cloudwatch log group exists for the uasset signed url group AWS Lambda function.
        """
        if self.prod_env:
            log_group_name = '/aws/lambda/SaintsXCTFUassetSignedUrlGroupPROD'
        else:
            log_group_name = '/aws/lambda/SaintsXCTFUassetSignedUrlGroupDEV'

        CloudWatchLogs.cloudwatch_log_group_exists(test_case=self, log_group_name=log_group_name, retention_days=7)
