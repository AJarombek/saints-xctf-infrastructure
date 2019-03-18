"""
Test suite for the Web Server and Launch Configuration.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 3/17/2019
"""

import masterTestFuncs as Test
from webserver import webserverTestFuncs as Func

tests = [
    lambda: Test.test(Func.test_webserver, "")
]


def webserver_test_suite() -> bool:
    """
    Execute all the tests related to the Web Server and Launch Configuration
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "WebApp Test Suite")
