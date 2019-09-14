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

    @staticmethod
    def get_subnet(name: str) -> dict:
        """
        Get a Subnet that matches a given name.
        :param name: Name of the Subnet in AWS.
        :return: A dictionary containing metadata about a Subnet.
        """
        subnets_response = ec2.describe_subnets(
            Filters=[{
                'Name': 'tag:Name',
                'Values': [name]
            }]
        )
        subnets = subnets_response.get('Subnets')

        if subnets is None:
            return {}
        else:
            return subnets[0]
