"""
Functions which represent Unit tests for the ACM HTTPS certificates and corresponding Route53 infrastructure
Author: Andrew Jarombek
Date: 3/4/2019
"""

import boto3

client = boto3.client('acm')


def acm_dev_wildcard_cert_exists() -> bool:
    """
    Test that the dev wildcard ACM certificate exists
    :return: True if the VPC is as expected, False otherwise
    """
    pass
