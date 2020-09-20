"""
Functions which represent Unit tests for RDS database backups.
Author: Andrew Jarombek
Date: 9/13/2019
"""

import unittest
import os

import boto3

from utils.Lambda import Lambda
from utils.IAM import IAM
from utils.VPC import VPC

try:
    prod_env = os.environ['TEST_ENV'] == "prod"
except KeyError:
    prod_env = True


class TestDatabaseSnapshot(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.aws_lambda = boto3.client('lambda')
        self.iam = boto3.client('iam')
        self.cloudwatch_event = boto3.client('events')
        self.ec2 = boto3.client('ec2')

        self.prod_env = prod_env

    def test_backup_lambda_function_exists(self) -> None:
        """
        Test that an AWS Lambda function for RDS backups exists as expected.
        :return: True if the function exists, False otherwise
        """
        if self.prod_env:
            function_name = 'SaintsXCTFMySQLBackupPROD'
        else:
            function_name = 'SaintsXCTFMySQLBackupDEV'

        lambda_function = self.aws_lambda.get_function(FunctionName=function_name)

        self.assertTrue(all([
            lambda_function.get('Configuration').get('FunctionName') == function_name,
            lambda_function.get('Configuration').get('Runtime') == 'python3.7',
            lambda_function.get('Configuration').get('Handler') == 'lambda.create_backup'
        ]))

    @unittest.skipIf(prod_env, 'SaintsXCTFMySQLRestorePROD lambda function not setup.')
    def test_restore_lambda_function_exists(self) -> None:
        """
        Test that an AWS Lambda function for restoring RDS instances from backups exists as expected.
        :return: True if the function exists, False otherwise
        """
        if self.prod_env:
            function_name = 'SaintsXCTFMySQLRestorePROD'
        else:
            function_name = 'SaintsXCTFMySQLRestoreDEV'

        lambda_function = self.aws_lambda.get_function(FunctionName=function_name)

        self.assertTrue(all([
            lambda_function.get('Configuration').get('FunctionName') == function_name,
            lambda_function.get('Configuration').get('Runtime') == 'python3.8',
            lambda_function.get('Configuration').get('Handler') == 'lambda.restore'
        ]))

    def test_backup_lambda_function_in_vpc(self) -> None:
        """
        Test that an AWS Lambda function for RDS backups exists in the proper VPC.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFMySQLBackupPROD'
        else:
            function_name = 'SaintsXCTFMySQLBackupDEV'

        lambda_function = self.aws_lambda.get_function(FunctionName=function_name)
        lambda_function_vpc_id = lambda_function.get('Configuration').get('VpcConfig').get('VpcId')

        vpc = VPC.get_vpc('saints-xctf-com-vpc')
        vpc_id = vpc.get('VpcId')

        self.assertTrue(vpc_id == lambda_function_vpc_id)

    @unittest.skipIf(prod_env, 'SaintsXCTFMySQLRestorePROD lambda function not setup.')
    def test_restore_lambda_function_in_vpc(self) -> None:
        """
        Test that an AWS Lambda function for RDS restoration from a backup exists in the proper VPC.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFMySQLRestorePROD'
        else:
            function_name = 'SaintsXCTFMySQLRestoreDEV'

        lambda_function = self.aws_lambda.get_function(FunctionName=function_name)
        lambda_function_vpc_id = lambda_function.get('Configuration').get('VpcConfig').get('VpcId')

        vpc = VPC.get_vpc('saints-xctf-com-vpc')
        vpc_id = vpc.get('VpcId')

        self.assertTrue(vpc_id == lambda_function_vpc_id)

    def test_backup_lambda_function_in_subnets(self) -> None:
        """
        Test that an AWS Lambda function for RDS backups exists in the proper subnets.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFMySQLBackupPROD'
        else:
            function_name = 'SaintsXCTFMySQLBackupDEV'

        self.assertTrue(Lambda.lambda_function_in_subnets(
            function_name=function_name,
            subnets=['saints-xctf-com-lisag-public-subnet', 'saints-xctf-com-megank-public-subnet']
        ))

    @unittest.skipIf(prod_env, 'SaintsXCTFMySQLRestorePROD lambda function not setup.')
    def test_restore_lambda_function_in_subnets(self) -> None:
        """
        Test that an AWS Lambda function for RDS restorations from backups exists in the proper subnets.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFMySQLRestorePROD'
        else:
            function_name = 'SaintsXCTFMySQLRestoreDEV'

        self.assertTrue(Lambda.lambda_function_in_subnets(
            function_name=function_name,
            subnets=['saints-xctf-com-lisag-public-subnet', 'saints-xctf-com-megank-public-subnet']
        ))

    def test_backup_lambda_function_has_iam_role(self) -> None:
        """
        Test that an AWS Lambda function for RDS backups has the proper IAM role.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFMySQLBackupPROD'
        else:
            function_name = 'SaintsXCTFMySQLBackupDEV'

        self.assertTrue(Lambda.lambda_function_has_iam_role(
            function_name=function_name,
            role_name='saints-xctf-rds-backup-lambda-role'
        ))

    def test_backup_lambda_function_role_exists(self) -> None:
        """
        Test that the saints-xctf-rds-backup-lambda-role IAM Role exists
        """
        self.assertTrue(IAM.iam_role_exists(role_name='saints-xctf-rds-backup-lambda-role'))

    def test_backup_lambda_function_policy_attached(self) -> None:
        """
        Test that the rds-backup-lambda-policy is attached to the saints-xctf-rds-backup-lambda-role
        """
        self.assertTrue(IAM.iam_policy_attached_to_role(
            role_name='saints-xctf-rds-backup-lambda-role',
            policy_name='rds-backup-lambda-policy'
        ))

    @unittest.skipIf(prod_env, 'SaintsXCTFMySQLRestorePROD lambda function not setup.')
    def test_restore_lambda_function_has_iam_role(self) -> None:
        """
        Test that an AWS Lambda function for restoring an RDS instance from a backup has the proper IAM role.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFMySQLRestorePROD'
        else:
            function_name = 'SaintsXCTFMySQLRestoreDEV'

        self.assertTrue(Lambda.lambda_function_has_iam_role(
            function_name=function_name,
            role_name='saints-xctf-rds-backup-lambda-role'
        ))

    def test_cloudwatch_event_rule_exists(self) -> None:
        """
        Test that a CloudWatch event exists as expected in my development environment.
        """
        if self.prod_env:
            cloudwatch_event_name = 'saints-xctf-rds-prod-backup-lambda-rule'
        else:
            cloudwatch_event_name = 'saints-xctf-rds-dev-backup-lambda-rule'

        cloudwatch_event_dict: dict = self.cloudwatch_event.describe_rule(Name=cloudwatch_event_name)

        self.assertTrue(all([
            cloudwatch_event_dict.get('Name') == cloudwatch_event_name,
            cloudwatch_event_dict.get('ScheduleExpression') == 'cron(0 7 * * ? *)'
        ]))

    def test_backup_lambda_function_has_security_group(self) -> None:
        """
        Test that the Lambda function for backing up an RDS instance has the expected security group.
        * For now, try to show him.  If you can show him how you feel, you won't feel the pressure to tell him.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFMySQLBackupPROD'
        else:
            function_name = 'SaintsXCTFMySQLBackupDEV'

        self.assertTrue(Lambda.lambda_function_has_security_group(
            function_name=function_name,
            sg_name='saints-xctf-lambda-rds-backup-security'
        ))

    @unittest.skipIf(prod_env, 'SaintsXCTFMySQLRestorePROD lambda function not setup.')
    def test_restore_lambda_function_has_security_group(self) -> None:
        """
        Test that the Lambda function restoring an RDS instance from a backup has the expected security group.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFMySQLRestorePROD'
        else:
            function_name = 'SaintsXCTFMySQLRestoreDEV'

        self.assertTrue(Lambda.lambda_function_has_security_group(
            function_name=function_name,
            sg_name='saints-xctf-lambda-rds-backup-security'
        ))

    def test_secrets_manager_vpc_endpoint_exists(self) -> None:
        """
        Test that the VPC endpoint for Secrets Manager exists.
        * And if you can't do that, have faith.  He will be there for you whenever you reach out.
        """
        vpc_endpoints = self.ec2.describe_vpc_endpoints(Filters=[
            {
                'Name': 'service-name',
                'Values': ['com.amazonaws.us-east-1.secretsmanager']
            }
        ])

        self.assertTrue(len(vpc_endpoints.get('VpcEndpoints')) == 1)

    def s3_vpc_endpoint_exists(self) -> None:
        """
        Test that the VPC endpoint for S3 exists.
        * If he loves you, he will understand why you can't do so now.
        """
        vpc_endpoints = self.ec2.describe_vpc_endpoints(Filters=[
            {
                'Name': 'service-name',
                'Values': ['com.amazonaws.us-east-1.s3']
            }
        ])

        self.assertTrue(len(vpc_endpoints.get('VpcEndpoints')) == 1)
