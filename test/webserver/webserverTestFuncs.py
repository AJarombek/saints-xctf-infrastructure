"""
Functions which represent Unit tests for the web server and launch configuration
Author: Andrew Jarombek
Date: 3/17/2019
"""

import boto3

ec2 = boto3.client('ec2')
sts = boto3.client('sts')

"""
Tests for all environments
"""


def ami_exists() -> bool:
    owner = sts.get_caller_identity().get('Account')
    amis = ec2.describe_images(
        Owners=[owner],
        Filters=[{
            'Name': 'name',
            'Values': ['saints-xctf-web-server*']
        }]
    )
    return len(amis.get('Images')) > 15


"""
Tests for the production environment
"""


def prod_instance_running() -> bool:
    instances = get_ec2('saints-xctf-server-prod-asg')
    return len(instances) > 0


def prod_instance_not_overscaled() -> bool:
    instances = get_ec2('saints-xctf-server-prod-asg')
    return len(instances) < 3


def prod_instance_profile_exists() -> bool:
    instances = get_ec2('saints-xctf-server-prod-asg')


"""
Tests for the development environment
"""


def dev_instance_running() -> bool:
    instances = get_ec2('saints-xctf-server-dev-asg')
    return len(instances) > 0


def dev_instance_not_overscaled() -> bool:
    instances = get_ec2('saints-xctf-server-dev-asg')
    return len(instances) < 3


def dev_instance_profile_exists() -> bool:
    instances = get_ec2('saints-xctf-server-dev-asg')


"""
Helper functions to use for retrieving EC2 information
"""


def get_ec2(name: str) -> list:
    """
    Get a list of running EC2 instances with a given name
    :param name: The name of EC2 instances to retrieve
    :return: A list of EC2 instances
    """
    filters = [
        {
            'Name': 'tag:Name',
            'Values': [name]
        },
        {
            'Name': 'instance-state-name',
            'Values': ['running']
        }
    ]

    return list(ec2.instances.filter(Filters=filters).all())
