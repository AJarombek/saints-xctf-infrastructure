"""
Unit tests for RDS database deployment infrastructure.
Author: Andrew Jarombek
Date: 9/19/2019
"""

import unittest
import os

import boto3
from boto3_type_annotations.s3 import Client as S3Client
from boto3_type_annotations.lambda_ import Client as LambdaClient
from boto3_type_annotations.iam import Client as IAMClient
from boto3_type_annotations.cloudwatch import Client as CloudWatchClient
from boto3_type_annotations.ec2 import Client as EC2Client

from utils.IAM import IAM
from utils.Lambda import Lambda
from utils.VPC import VPC

try:
    prod_env = os.environ['TEST_ENV'] == "prod"
except KeyError:
    prod_env = True


class TestDatabaseDeployment(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.aws_lambda: LambdaClient = boto3.client('lambda')
        self.iam: IAMClient = boto3.client('iam')
        self.cloudwatch_event: CloudWatchClient = boto3.client('events')
        self.ec2: EC2Client = boto3.client('ec2')
        self.s3: S3Client = boto3.client('s3')

        self.prod_env = prod_env

    def test_deployment_lambda_function_exists(self) -> None:
        """
        Test that an AWS Lambda function for RDS script deployments exists as expected.
        :return: True if the function exists, False otherwise
        """
        if self.prod_env:
            function_name = 'SaintsXCTFDatabaseDeploymentPROD'
        else:
            function_name = 'SaintsXCTFDatabaseDeploymentDEV'

        lambda_function = self.aws_lambda.get_function(FunctionName=function_name)

        self.assertTrue(all([
            lambda_function.get('Configuration').get('FunctionName') == function_name,
            lambda_function.get('Configuration').get('Runtime') == 'python3.8',
            lambda_function.get('Configuration').get('Handler') == 'lambda.deploy'
        ]))

    def test_deployment_lambda_function_in_vpc(self) -> None:
        """
        Test that an AWS Lambda function for RDS database deployments exists in the proper VPC.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFDatabaseDeploymentPROD'
        else:
            function_name = 'SaintsXCTFDatabaseDeploymentDEV'

        lambda_function = self.aws_lambda.get_function(FunctionName=function_name)
        lambda_function_vpc_id = lambda_function.get('Configuration').get('VpcConfig').get('VpcId')

        vpc = VPC.get_vpc('saints-xctf-com-vpc')
        vpc_id = vpc.get('VpcId')

        self.assertTrue(vpc_id == lambda_function_vpc_id)

    def test_deployment_lambda_function_in_subnets(self) -> None:
        """
        Test that an AWS Lambda function for RDS database deployments exists in the proper subnets.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFDatabaseDeploymentPROD'
        else:
            function_name = 'SaintsXCTFDatabaseDeploymentDEV'

        self.assertTrue(Lambda.lambda_function_in_subnets(
            function_name=function_name,
            subnets=['saints-xctf-com-lisag-public-subnet', 'saints-xctf-com-megank-public-subnet']
        ))

    def test_backup_lambda_function_has_iam_role(self) -> None:
        """
        Test that an AWS Lambda function for RDS database deployments has the proper IAM role.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFMySQLDatabaseDeploymentPROD'
        else:
            function_name = 'SaintsXCTFMySQLDatabaseDeploymentDEV'

        self.assertTrue(Lambda.lambda_function_has_iam_role(
            function_name=function_name,
            role_name='saints-xctf-database-deployment-lambda-role'
        ))

    def test_backup_lambda_function_role_exists(self) -> None:
        """
        Test that the saints-xctf-database-deployment-lambda-role IAM Role exists
        """
        self.assertTrue(IAM.iam_role_exists(role_name='saints-xctf-database-deployment-lambda-role'))

    def test_backup_lambda_function_policy_attached(self) -> None:
        """
        Test that the rds-backup-lambda-policy is attached to the saints-xctf-database-deployment-lambda-role
        """
        self.assertTrue(IAM.iam_policy_attached_to_role(
            role_name='saints-xctf-database-deployment-lambda-role',
            policy_name='saints-xctf-database-deployment-lambda-policy'
        ))
