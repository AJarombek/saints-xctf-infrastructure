"""
Testing Suite for my AWS infrastructure
Author: Andrew Jarombek
Date: 2/23/2019
"""

import boto3

# Test Bastion
ec2 = boto3.resource('ec2')

filters = [
    {
        'Name': 'bastion-host',
        'Values': ['running']
    }
]

instances = ec2.instances.filter(Filters=filters)


def test(func: function, title: str) -> bool:
    """
    Wrapper function for testing an AWS resource
    :param func: a function to execute, must return a boolean value
    :param title: describes the test
    :return: True if the test succeeds, false otherwise
    """

    result = func()

    if result:
        print(f"\u2713 Success {title}")
        return True
    else:
        print(f"\u274C Failure {title}")
        return False
