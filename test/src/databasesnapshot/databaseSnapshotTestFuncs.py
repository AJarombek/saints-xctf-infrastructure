"""
Functions which represent Unit tests for RDS database backups.
Author: Andrew Jarombek
Date: 9/13/2019
"""

import boto3

aws_lambda = boto3.client('lambda')


def prod_lambda_function_exists():
    return lambda_function_exists(function_name='SaintsXCTFMySQLBackupPROD')


def dev_lambda_function_exists():
    return lambda_function_exists(function_name='SaintsXCTFMySQLBackupDEV')


def lambda_function_exists(function_name):
    lambda_function = aws_lambda.get_function(FunctionName=function_name)

    return all([
        lambda_function.get('FunctionName') == function_name,
        lambda_function.get('Runtime') == 'python3.7',
        lambda_function.get('Handler') == 'lambda.create_backup'
    ])
