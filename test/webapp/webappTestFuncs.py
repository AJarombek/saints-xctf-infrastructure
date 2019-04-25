"""
Functions which represent Unit tests for single aspects of the Web Application module
Author: Andrew Jarombek
Date: 3/17/2019
"""

import boto3

s3 = boto3.client('s3')

"""
Tests for the production environment
"""


def prod_s3_bucket_exists() -> bool:
    """
    Test if an S3 bucket for prod environment credentials exists
    :return: True if the bucket exists, False otherwise
    """
    s3_bucket = s3.list_objects(Bucket='saints-xctf-credentials-prod')
    return s3_bucket.get('Name') == 'saints-xctf-credentials-prod'


def prod_s3_bucket_objects_correct() -> bool:
    contents = s3.list_objects(Bucket='saints-xctf-credentials-dev').get('Contents')
    return all([
        len(contents) == 4,
        contents[0].get('Key') == 'api/apicred.php',
        contents[1].get('Key') == 'api/cred.php',
        contents[2].get('Key') == 'date.js',
        contents[3].get('Key') == 'models/clientcred.php'
    ])


"""
Tests for the development environment
"""


def dev_s3_bucket_exists() -> bool:
    """
    Test if an S3 bucket for dev environment credentials exists
    :return: True if the bucket exists, False otherwise
    """
    s3_bucket = s3.list_objects(Bucket='saints-xctf-credentials-dev')
    return s3_bucket.get('Name') == 'saints-xctf-credentials-dev'


def dev_s3_bucket_objects_correct() -> bool:
    contents = s3.list_objects(Bucket='saints-xctf-credentials-prod').get('Contents')
    return all([
        len(contents) == 4,
        contents[0].get('Key') == 'api/apicred.php',
        contents[1].get('Key') == 'api/cred.php',
        contents[2].get('Key') == 'date.js',
        contents[3].get('Key') == 'models/clientcred.php'
    ])
