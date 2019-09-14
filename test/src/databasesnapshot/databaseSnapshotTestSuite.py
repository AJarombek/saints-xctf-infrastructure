"""
Test suite for a lambda function which creates RDS database backups.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 9/13/2019
"""

import os
import masterTestFuncs as Test
from databasesnapshot import databaseSnapshotTestFuncs as Func

try:
    prod_env = os.environ['TEST_ENV'] == "prod"
except KeyError:
    prod_env = True

tests = [
    lambda: Test.test(Func.lambda_function_role_exists, "Assert that the IAM role for the lambda function exists"),
    lambda: Test.test(Func.lambda_function_policy_attached, "Assert that the proper IAM policy is attached to the role")
]

if prod_env:
    prod_tests = [
        lambda: Test.test(Func.prod_lambda_function_exists, "Prove that the Lambda Function for RDS backups exists"),
        lambda: Test.test(Func.prod_lambda_function_in_vpc, "Lambda Function in the proper VPC"),
        lambda: Test.test(Func.prod_lambda_function_in_subnets, "Lambda Function in the proper Subnets"),
        lambda: Test.test(Func.prod_lambda_function_has_iam_role, "Lambda Function has the expected IAM role attached")
    ]
    tests += prod_tests
else:
    dev_tests = [
        lambda: Test.test(Func.dev_lambda_function_exists, "Prove that the Lambda Function for RDS backups exists"),
        lambda: Test.test(Func.dev_lambda_function_in_vpc, "Lambda Function in the proper VPC"),
        lambda: Test.test(Func.dev_lambda_function_in_subnets, "Lambda Function in the proper Subnets"),
        lambda: Test.test(Func.dev_lambda_function_has_iam_role, "Lambda Function has the expected IAM role attached")
    ]
    tests += dev_tests


def database_snapshot_test_suite() -> bool:
    """
    Execute all the tests related to the Database Backup Lambda Function.
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "Database Snapshot Test Suite")
