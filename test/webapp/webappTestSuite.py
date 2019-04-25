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
    prod_env = False

tests = [
    lambda: Test.test(Func.prod_creds_s3_bucket_exists, "")
]

if prod_env:
    prod_tests = [
        lambda: Test.test(Func.prod_creds_s3_bucket_exists, "")
    ]
    tests += prod_tests
else:
    dev_tests = [
        lambda: Test.test(Func.dev_creds_s3_bucket_exists, "")
    ]
    tests += dev_tests


def webapp_test_suite() -> bool:
    """
    Execute all the tests related to the Web Application module
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "WebApp Test Suite")
