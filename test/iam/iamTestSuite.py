"""
Test suite for the IAM roles and policies.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 3/17/2019
"""

import masterTestFuncs as Test
from iam import iamTestFuncs as Func

tests = [
    lambda: Test.test(Func.rds_access_role_exists, ""),
    lambda: Test.test(Func.s3_access_role_exists, ""),
    lambda: Test.test(Func.rds_access_policy_attached, ""),
    lambda: Test.test(Func.s3_access_policy_attached, "")
]


def iam_test_suite() -> bool:
    """
    Execute all the tests related to the IAM roles and policies
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "IAM Test Suite")
