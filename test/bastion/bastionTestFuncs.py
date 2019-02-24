"""
Author: Andrew Jarombek
Date: 2/23/2019
"""

import boto3

ec2 = boto3.resource('ec2')
s3 = boto3.resource('s3')


def bastionec2running():
    """
    Test that the Bastion EC2 instance is running
    :return: True if the instance is running, False otherwise
    """
    filters = [
        {
            'Name': 'tag:Name',
            'Values': ['bastion-host']
        },
        {
            'Name': 'instance-state-name',
            'Values': ['running']
        }
    ]

    instances = list(ec2.instances.filter(Filters=filters).all())
    return len(instances) == 1
