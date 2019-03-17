"""
Test suite for the Web Application module.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 3/17/2019
"""

import masterTestFuncs as Test
from webapp import webappTestFuncs as Func

tests = [
    lambda: Test.test(Func.test_webapp, "")
]


def webapp_test_suite() -> bool:
    """
    Execute all the tests related to the Web Application module
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "WebApp Test Suite")
