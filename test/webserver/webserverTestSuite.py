"""
Test suite for the Web Server and Launch Configuration.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 3/17/2019
"""

import os
import masterTestFuncs as Test
from webserver import webserverTestFuncs as Func

# Get the infrastructure environment to test (from an environment variable)
try:
    prod_env = os.environ['TEST_ENV'] == "prod"
except KeyError:
    prod_env = False

tests = [
    lambda: Test.test(Func.test_webserver, "")
]

if prod_env:
    prod_tests = [
        lambda: Test.test(Func.prod_s3_bucket_exists, "")
    ]
    tests += prod_tests
else:
    dev_tests = [
        lambda: Test.test(Func.dev_s3_bucket_exists, "")
    ]
    tests += dev_tests


def webserver_test_suite() -> bool:
    """
    Execute all the tests related to the Web Server and Launch Configuration
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "WebApp Test Suite")
