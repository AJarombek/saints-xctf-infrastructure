"""
Test suite for the Secrets Manager credentials.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 9/12/2019
"""

import os
import masterTestFuncs as Test
from secretsmanager import secretsManagerTestFuncs as Func

try:
    prod_env = os.environ['TEST_ENV'] == "prod"
except KeyError:
    prod_env = True

tests = []

if prod_env:
    prod_tests = [
        lambda: Test.test(Func.prod_rds_secrets_exist, "Confirm that secrets exist in Secrets Manager")
    ]
    tests += prod_tests
else:
    dev_tests = [
        lambda: Test.test(Func.dev_rds_secrets_exist, "Confirm that secrets exist in Secrets Manager")
    ]
    tests += dev_tests


def iam_test_suite() -> bool:
    """
    Execute all the tests related to the IAM roles and policies
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "Secrets Manager Test Suite")
