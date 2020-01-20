"""
Functions which represent Unit tests for RDS database backups.
Author: Andrew Jarombek
Date: 9/13/2019
"""

import boto3
from utils.VPC import VPC
from utils.SecurityGroup import SecurityGroup

aws_lambda = boto3.client('lambda')
iam = boto3.client('iam')
cloudwatch_event = boto3.client('events')
ec2 = boto3.client('ec2')


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
        lambda_function.get('Configuration').get('FunctionName') == function_name,
        lambda_function.get('Configuration').get('Runtime') == 'python3.7',
        lambda_function.get('Configuration').get('Handler') == 'lambda.create_backup'
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
    lambda_function = aws_lambda.get_function(FunctionName=function_name)
    lambda_function_subnets: list = lambda_function.get('Configuration').get('VpcConfig').get('SubnetIds')

    first_subnet_dict = VPC.get_subnet(first_subnet)
    first_subnet_id = first_subnet_dict.get('SubnetId')

    second_subnet_dict = VPC.get_subnet(second_subnet)
    second_subnet_id = second_subnet_dict.get('SubnetId')

    return all([
        len(lambda_function_subnets) == 2,
        first_subnet_id in lambda_function_subnets,
        second_subnet_id in lambda_function_subnets
    ])


def prod_lambda_function_has_iam_role() -> bool:
    """
    Test that an AWS Lambda function for RDS backups in my production environment has the proper IAM role.
    :return: True if the lambda function is in the proper subnets, False otherwise.
    """
    return lambda_function_has_iam_role(function_name='SaintsXCTFMySQLBackupPROD')


def dev_lambda_function_has_iam_role() -> bool:
    """
    Test that an AWS Lambda function for RDS backups in my development environment has the proper IAM role.
    :return: True if the lambda function is in the proper subnets, False otherwise.
    """
    return lambda_function_has_iam_role(function_name='SaintsXCTFMySQLBackupDEV')


def lambda_function_has_iam_role(function_name: str) -> bool:
    """
    Test that an AWS Lambda function for RDS backups has the proper IAM role.
    :param function_name: The name of the AWS Lambda function to search for.
    :return: True if the lambda function is in the proper subnets, False otherwise.
    """
    lambda_function = aws_lambda.get_function(FunctionName=function_name)
    lambda_function_iam_role: list = lambda_function.get('Configuration').get('Role')
    return 'saints-xctf-rds-backup-lambda-role' in lambda_function_iam_role


def lambda_function_role_exists() -> bool:
    """
    Test that the saints-xctf-rds-backup-lambda-role IAM Role exists
    :return: True if the IAM role exists, False otherwise
    """
    role_dict = iam.get_role(RoleName='saints-xctf-rds-backup-lambda-role')
    role = role_dict.get('Role')
    return role.get('RoleName') == 'saints-xctf-rds-backup-lambda-role'


def lambda_function_policy_attached() -> bool:
    """
    Test that the rds-backup-lambda-policy is attached to the saints-xctf-rds-backup-lambda-role
    :return: True if the policy is attached to the role, False otherwise
    """
    policy_response = iam.list_attached_role_policies(RoleName='saints-xctf-rds-backup-lambda-role')
    policies = policy_response.get('AttachedPolicies')
    s3_policy = policies[0]
    return len(policies) == 1 and s3_policy.get('PolicyName') == 'rds-backup-lambda-policy'


def prod_cloudwatch_event_rule_exists() -> bool:
    """
    Test that a CloudWatch event exists as expected in my production environment.
    :return: True if the CloudWatch event exists as expected, False otherwise.
    """
    return cloudwatch_event_rule_exists(cloudwatch_event_name='saints-xctf-rds-prod-backup-lambda-rule')


def dev_cloudwatch_event_rule_exists() -> bool:
    """
    Test that a CloudWatch event exists as expected in my development environment.
    :return: True if the CloudWatch event exists as expected, False otherwise.
    """
    return cloudwatch_event_rule_exists(cloudwatch_event_name='saints-xctf-rds-dev-backup-lambda-rule')


def cloudwatch_event_rule_exists(cloudwatch_event_name: str) -> bool:
    """
    Test that a CloudWatch event exists as expected in my development environment.
    :param cloudwatch_event_name: The name of the CloudWatch event.
    :return: True if the CloudWatch event exists as expected, False otherwise.
    """
    cloudwatch_event_dict: dict = cloudwatch_event.describe_rule(Name=cloudwatch_event_name)

    return all([
        cloudwatch_event_dict.get('Name') == cloudwatch_event_name,
        cloudwatch_event_dict.get('ScheduleExpression') == 'cron(0 7 * * ? *)'
    ])


def prod_lambda_function_has_security_group() -> bool:
    """
    Test that the Lambda function has the expected security group in my production environment.
    :return: True if the lambda function has the expected security group, False otherwise.
    """
    return lambda_function_has_security_group(function_name='SaintsXCTFMySQLBackupPROD')


def dev_lambda_function_has_security_group() -> bool:
    """
    Test that the Lambda function has the expected security group in my development environment.
    * Don't be afraid, when you are ready you will know how to tell him.
    :return: True if the lambda function has the expected security group, False otherwise.
    """
    return lambda_function_has_security_group(function_name='SaintsXCTFMySQLBackupDEV')


def lambda_function_has_security_group(function_name: str) -> bool:
    """
    Test that the Lambda function has the expected security group.
    * For now, try to show him.  If you can show him how you feel, you won't feel the pressure to tell him.
    :param function_name: The name of the AWS Lambda function to search for.
    :return: True if the Lambda function has the saints-xctf-lambda-rds-backup-security security group, False otherwise.
    """
    lambda_function = aws_lambda.get_function(FunctionName=function_name)
    lambda_function_sgs: list = lambda_function.get('Configuration').get('VpcConfig').get('SecurityGroupIds')
    security_group_id = lambda_function_sgs[0]

    sg = SecurityGroup.get_security_group('saints-xctf-lambda-rds-backup-security')

    return all([
        len(lambda_function_sgs) == 1,
        security_group_id == sg.get('GroupId')
    ])


def secrets_manager_vpc_endpoint_exists() -> bool:
    """
    Test that the VPC endpoint for Secrets Manager exists.
    * And if you can't do that, have faith.  He will be there for you whenever you reach out.
    :return: True if the VPC endpoint for Secrets Manager exists, False otherwise.
    """
    vpc_endpoints = ec2.describe_vpc_endpoints(Filters=[
        {
            'Name': 'service-name',
            'Values': ['com.amazonaws.us-east-1.secretsmanager']
        }
    ])

    return len(vpc_endpoints.get('VpcEndpoints')) == 1


def s3_vpc_endpoint_exists() -> bool:
    """
    Test that the VPC endpoint for S3 exists.
    * If he loves you, he will understand why you can't do so now.
    :return: True if the VPC endpoint for S3 exists, False otherwise.
    """
    vpc_endpoints = ec2.describe_vpc_endpoints(Filters=[
        {
            'Name': 'service-name',
            'Values': ['com.amazonaws.us-east-1.s3']
        }
    ])

    return len(vpc_endpoints.get('VpcEndpoints')) == 1
