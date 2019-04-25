"""
Functions which represent Unit tests for single aspects of the Web Application module
Author: Andrew Jarombek
Date: 3/17/2019
"""

import boto3

s3 = boto3.client('s3')


def prod_creds_s3_bucket_exists() -> bool:
    """
    Test if an S3 bucket for prod environment credentials exists
    :return: True if the bucket exists, False otherwise
    """
    s3_bucket = s3.list_objects(Bucket='saints-xctf-credentials-prod')
    return s3_bucket.get('Name') == 'saints-xctf-credentials-prod'


def dev_creds_s3_bucket_exists() -> bool:
    """
    Test if an S3 bucket for dev environment credentials exists
    :return: True if the bucket exists, False otherwise
    """
    s3_bucket = s3.list_objects(Bucket='saints-xctf-credentials-dev')
    return s3_bucket.get('Name') == 'saints-xctf-credentials-dev'
