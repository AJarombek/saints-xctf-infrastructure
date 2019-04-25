"""
Functions which represent Unit tests for the web server and launch configuration
Author: Andrew Jarombek
Date: 3/17/2019
"""

import boto3

ec2 = boto3.resource('ec2')

"""
Tests for all environments
"""


def ami_exists() -> dict:
    pass


"""
Tests for the production environment
"""


def prod_instance_profile_exists() -> dict:
    pass


"""
Tests for the development environment
"""


def dev_instance_profile_exists() -> dict:
    pass