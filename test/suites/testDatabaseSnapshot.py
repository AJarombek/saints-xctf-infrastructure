"""
Functions which represent Unit tests for RDS database backups.
Author: Andrew Jarombek
Date: 9/13/2019
"""

import unittest
import os

import boto3
from utils.VPC import VPC
from utils.SecurityGroup import SecurityGroup

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

    @unittest.skipIf(prod_env == 'dev', 'SaintsXCTFMySQLBackupDEV lambda function not setup in development.')
    def test_lambda_function_exists(self) -> None:
        """
        Test that an AWS Lambda function for RDS backups exists as expected.
        :return: True if the credentials exist, False otherwise
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

    @unittest.skipIf(prod_env == 'dev', 'SaintsXCTFMySQLBackupDEV lambda function not setup in development.')
    def test_lambda_function_in_vpc(self) -> None:
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

    @unittest.skipIf(prod_env == 'dev', 'SaintsXCTFMySQLBackupDEV lambda function not setup in development.')
    def test_lambda_function_in_subnets(self) -> None:
        """
        Test that an AWS Lambda function for RDS backups exists in the proper subnets.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFMySQLBackupPROD'
        else:
            function_name = 'SaintsXCTFMySQLBackupDEV'

        lambda_function = self.aws_lambda.get_function(FunctionName=function_name)
        lambda_function_subnets: list = lambda_function.get('Configuration').get('VpcConfig').get('SubnetIds')

        first_subnet_dict = VPC.get_subnet('saints-xctf-com-lisag-public-subnet')
        first_subnet_id = first_subnet_dict.get('SubnetId')

        second_subnet_dict = VPC.get_subnet('saints-xctf-com-megank-public-subnet')
        second_subnet_id = second_subnet_dict.get('SubnetId')

        self.assertTrue(all([
            len(lambda_function_subnets) == 2,
            first_subnet_id in lambda_function_subnets,
            second_subnet_id in lambda_function_subnets
        ]))

    @unittest.skipIf(prod_env == 'dev', 'SaintsXCTFMySQLBackupDEV lambda function not setup in development.')
    def test_lambda_function_has_iam_role(self) -> None:
        """
        Test that an AWS Lambda function for RDS backups has the proper IAM role.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFMySQLBackupPROD'
        else:
            function_name = 'SaintsXCTFMySQLBackupDEV'

        lambda_function = self.aws_lambda.get_function(FunctionName=function_name)
        lambda_function_iam_role: list = lambda_function.get('Configuration').get('Role')
        self.assertTrue('saints-xctf-rds-backup-lambda-role' in lambda_function_iam_role)

    def test_lambda_function_role_exists(self) -> None:
        """
        Test that the saints-xctf-rds-backup-lambda-role IAM Role exists
        """
        role_dict = self.iam.get_role(RoleName='saints-xctf-rds-backup-lambda-role')
        role = role_dict.get('Role')
        self.assertTrue(role.get('RoleName') == 'saints-xctf-rds-backup-lambda-role')

    def test_lambda_function_policy_attached(self) -> None:
        """
        Test that the rds-backup-lambda-policy is attached to the saints-xctf-rds-backup-lambda-role
        """
        policy_response = self.iam.list_attached_role_policies(RoleName='saints-xctf-rds-backup-lambda-role')
        policies = policy_response.get('AttachedPolicies')
        s3_policy = policies[0]
        self.assertTrue(len(policies) == 1)
        self.assertTrue(s3_policy.get('PolicyName') == 'rds-backup-lambda-policy')

    @unittest.skipIf(prod_env == 'dev', 'SaintsXCTFMySQLBackupDEV lambda function not setup in development.')
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

    @unittest.skipIf(prod_env == 'dev', 'SaintsXCTFMySQLBackupDEV lambda function not setup in development.')
    def test_lambda_function_has_security_group(self) -> bool:
        """
        Test that the Lambda function has the expected security group.
        * For now, try to show him.  If you can show him how you feel, you won't feel the pressure to tell him.
        """
        if self.prod_env:
            function_name = 'SaintsXCTFMySQLBackupPROD'
        else:
            function_name = 'SaintsXCTFMySQLBackupDEV'

        lambda_function = self.aws_lambda.get_function(FunctionName=function_name)
        lambda_function_sgs: list = lambda_function.get('Configuration').get('VpcConfig').get('SecurityGroupIds')
        security_group_id = lambda_function_sgs[0]

        sg = SecurityGroup.get_security_group('saints-xctf-lambda-rds-backup-security')

        return all([
            len(lambda_function_sgs) == 1,
            security_group_id == sg.get('GroupId')
        ])

    def test_secrets_manager_vpc_endpoint_exists(self) -> bool:
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

        return len(vpc_endpoints.get('VpcEndpoints')) == 1

    def s3_vpc_endpoint_exists(self) -> bool:
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

        return len(vpc_endpoints.get('VpcEndpoints')) == 1
