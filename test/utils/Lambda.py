"""
Helper functions for AWS Lambda functions.
Author: Andrew Jarombek
Date: 9/19/2020
"""

import boto3
from boto3_type_annotations.lambda_ import Client as LambdaClient

from utils.VPC import VPC
from utils.SecurityGroup import SecurityGroup

aws_lambda: LambdaClient = boto3.client('lambda')


class Lambda:

    @staticmethod
    def lambda_function_in_subnets(function_name: str, subnets: list) -> bool:
        """
        Test that an AWS Lambda function exists in the proper subnets.
        :param function_name: AWS Lambda function name.
        :param subnets: List of subnet names.
        """
        lambda_function = aws_lambda.get_function(FunctionName=function_name)
        lambda_function_subnets: list = lambda_function.get('Configuration').get('VpcConfig').get('SubnetIds')

        proper_subnets = True
        for subnet in subnets:
            subnet_dict = VPC.get_subnet(subnet)
            subnet_id = subnet_dict.get('SubnetId')

            if subnet_id not in lambda_function_subnets:
                proper_subnets = False

        return all([
            len(lambda_function_subnets) == len(subnets),
            proper_subnets
        ])

    @staticmethod
    def lambda_function_has_iam_role(function_name: str, role_name: str) -> bool:
        """
        Test that an AWS Lambda function has an IAM role.
        :param function_name: AWS Lambda function name.
        :param role_name: Name of the IAM Role.
        """
        lambda_function = aws_lambda.get_function(FunctionName=function_name)
        lambda_function_iam_role: list = lambda_function.get('Configuration').get('Role')
        return role_name in lambda_function_iam_role

    @staticmethod
    def lambda_function_has_security_group(function_name: str, sg_name: str) -> bool:
        """
        Test that the Lambda function has the expected security group.
        :param function_name: AWS Lambda function name.
        :param sg_name: Name of the security group.
        """
        lambda_function = aws_lambda.get_function(FunctionName=function_name)
        lambda_function_sgs: list = lambda_function.get('Configuration').get('VpcConfig').get('SecurityGroupIds')
        security_group_id = lambda_function_sgs[0]

        sg = SecurityGroup.get_security_group(sg_name)

        return all([
            len(lambda_function_sgs) == 1,
            security_group_id == sg.get('GroupId')
        ])
