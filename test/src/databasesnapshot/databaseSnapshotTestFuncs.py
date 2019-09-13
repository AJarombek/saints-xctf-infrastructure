"""
Functions which represent Unit tests for RDS database backups.
Author: Andrew Jarombek
Date: 9/13/2019
"""

import boto3
from utils.VPC import VPC

aws_lambda = boto3.client('lambda')


def prod_lambda_function_exists() -> bool:
    """
    Test that the SaintsXCTF production RDS backup function exists.
    :return: True if the lambda function exists as expected, False otherwise
    """
    return lambda_function_exists(function_name='SaintsXCTFMySQLBackupPROD')


def dev_lambda_function_exists() -> bool:
    """
    Test that the SaintsXCTF development RDS backup function exists.
    :return: True if the lambda function exists as expected, False otherwise
    """
    return lambda_function_exists(function_name='SaintsXCTFMySQLBackupDEV')


def lambda_function_exists(function_name: str) -> bool:
    """
    Test that an AWS Lambda function for RDS backups exists as expected.
    :param function_name: The name of the AWS Lambda function to search for.
    :return: True if the credentials exist, False otherwise
    """
    lambda_function = aws_lambda.get_function(FunctionName=function_name)

    return all([
        lambda_function.get('FunctionName') == function_name,
        lambda_function.get('Runtime') == 'python3.7',
        lambda_function.get('Handler') == 'lambda.create_backup'
    ])


def prod_lambda_function_in_vpc() -> bool:
    """
    Test that an AWS Lambda function for RDS backups in my production environment exists in the proper VPC.
    :return: True if the lambda function is in the proper VPC, False otherwise.
    """
    return lambda_function_in_vpc(function_name='SaintsXCTFMySQLBackupPROD', vpc_name='saints-xctf-com-vpc')


def dev_lambda_function_in_vpc() -> bool:
    """
    Test that an AWS Lambda function for RDS backups in my development environment exists in the proper VPC.
    :return: True if the lambda function is in the proper VPC, False otherwise.
    """
    return lambda_function_in_vpc(function_name='SaintsXCTFMySQLBackupDEV', vpc_name='saints-xctf-com-vpc')


def lambda_function_in_vpc(function_name: str, vpc_name: str) -> bool:
    """
    Test that an AWS Lambda function for RDS backups exists in the proper VPC.
    :param function_name: The name of the AWS Lambda function to search for.
    :param vpc_name: VPC the lambda function should live in.
    :return: True if the lambda function is in the VPC supplied, False otherwise.
    """
    lambda_function = aws_lambda.get_function(FunctionName=function_name)
    lambda_function_vpc_id = lambda_function.get('Configuration').get('VpcConfig').get('VpcId')

    vpc = VPC.get_vpc(vpc_name)
    vpc_id = vpc.get('VpcId')

    return vpc_id == lambda_function_vpc_id


def prod_lambda_function_in_subnets() -> bool:
    """
    Test that an AWS Lambda function for RDS backups in my production environment exists in the proper subnets.
    :return: True if the lambda function is in the proper subnets, False otherwise.
    """
    return lambda_function_in_subnets(
        function_name='SaintsXCTFMySQLBackupPROD',
        first_subnet='saints-xctf-com-lisag-public-subnet',
        second_subnet='saints-xctf-com-megank-public-subnet'
    )


def dev_lambda_function_in_subnets() -> bool:
    """
    Test that an AWS Lambda function for RDS backups in my development environment exists in the proper subnets.
    :return: True if the lambda function is in the proper subnets, False otherwise.
    """
    return lambda_function_in_subnets(
        function_name='SaintsXCTFMySQLBackupDEV',
        first_subnet='saints-xctf-com-lisag-public-subnet',
        second_subnet='saints-xctf-com-megank-public-subnet'
    )


def lambda_function_in_subnets(function_name: str, first_subnet: str, second_subnet: str) -> bool:
    """
    Test that an AWS Lambda function for RDS backups exists in the proper subnets.
    :param function_name: The name of the AWS Lambda function to search for.
    :param first_subnet: The first subnet that the AWS Lambda function should live in.
    :param second_subnet: The second subnet that the AWS Lambda function should live in.
    :return: True if the lambda function is in the subnets supplied, False otherwise.
    """
    pass
