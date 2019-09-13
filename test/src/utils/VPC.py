"""
Helper functions for VPCs
Author: Andrew Jarombek
Date: 9/13/2019
"""

import boto3

ec2 = boto3.client('ec2')


class VPC:

    @staticmethod
    def get_vpc(name: str) -> dict:
        """
        Get a single VPC that matches a given name.
        :param name: Name of the VPC in AWS.
        :return: A dictionary containing metadata about a VPC.
        """
        vpcs_response = ec2.describe_vpcs(
            Filters=[{
                'Name': 'tag:Name',
                'Values': [name]
            }]
        )
        vpcs = vpcs_response.get('Vpcs')

        if vpcs is None:
            return {}
        else:
            return vpcs[0]
