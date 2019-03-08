"""
Test suite for the RDS and database backups.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 3/5/2019
"""

import masterTestFuncs as Test
from database import databaseTestFuncs as Func

tests = [
    lambda: Test.test(Func.rds_prod_running, "Prod MySQL RDS Instance Running"),
    lambda: Test.test(Func.rds_dev_running, "Dev MySQL RDS Instance Running"),
    lambda: Test.test(Func.rds_prod_engine_as_expected, "Prod MySQL RDS Instance Using Proper MySQL Version"),
    lambda: Test.test(Func.rds_dev_engine_as_expected, "Dev MySQL RDS Instance Using Proper MySQL Version")
]


def database_test_suite() -> bool:
    """
    Execute all the tests related to the RDS databases
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "Database Test Suite")
