"""
Helper functions for Security Groups
Author: Andrew Jarombek
Date: 9/14/2019
"""

import boto3

ec2 = boto3.client('ec2')


class SecurityGroup:

    @staticmethod
    def get_security_group(name: str) -> dict:
        """
        Get a single Security Group that matches a given name.
        :param name: Name of the Security Group in AWS.
        :return: A dictionary containing data about a Security Group.
        """
        security_groups_response = ec2.describe_security_groups(
            Filters=[{
                'Name': 'tag:Name',
                'Values': [name]
            }]
        )
        security_groups = security_groups_response.get('SecurityGroups')

        if security_groups is None:
            return {}
        else:
            return security_groups[0]
