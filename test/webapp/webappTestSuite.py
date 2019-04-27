"""
Test suite for the Web Application module.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 3/17/2019
"""

import os
import masterTestFuncs as Test
from webapp import webappTestFuncs as Func

# Get the infrastructure environment to test (from an environment variable)
try:
    prod_env = os.environ['TEST_ENV'] == "prod"
except KeyError:
    prod_env = True

tests = []

if prod_env:
    prod_tests = [
        lambda: Test.test(Func.prod_s3_bucket_exists, "Determine if the Production S3 Bucket Exists"),
        lambda: Test.test(Func.prod_s3_bucket_objects_correct, "Validate the Production S3 Buckets Contents")
    ]
    tests += prod_tests
else:
    dev_tests = [
        lambda: Test.test(Func.dev_s3_bucket_exists, "Determine if the Development S3 Bucket Exists"),
        lambda: Test.test(Func.dev_s3_bucket_objects_correct, "Validate the Development S3 Buckets Contents")
    ]
    tests += dev_tests


def webapp_test_suite() -> bool:
    """
    Execute all the tests related to the Web Application module
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "WebApp Test Suite")
