"""
Test suite for the RDS and database backups.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 3/5/2019
"""

import masterTestFuncs as Test
from database import databaseTestFuncs as Func

tests = [
    lambda: Test.test(Func.rds_running, "MySQL RDS Instance Running"),
    lambda: Test.test(Func.rds_engine_as_expected, "MySQL RDS Instance Using Proper MySQL Version"),
    lambda: Test.test(Func.rds_in_proper_subnets, "MySQL RDS Instance In Proper Subnets"),
    lambda: Test.test(Func.s3_backup_bucket_exists, "MySQL RDS Instance Has an S3 Bucket for Backups")
]


def database_test_suite() -> bool:
    """
    Execute all the tests related to the RDS databases
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "Database Test Suite")
