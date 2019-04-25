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
    lambda: Test.test(Func.ami_exists, "Confirm one or more AMIs Exist for SaintsXCTF")
]

if prod_env:
    prod_tests = [
        lambda: Test.test(Func.prod_instance_running, "Confirm that the Production EC2 Instance is Running"),
        lambda: Test.test(Func.prod_instance_not_overscaled, "Ensure there are an Expected Number of Instances"),
        lambda: Test.test(Func.prod_instance_profile_exists, "Ensure the EC2 Instance has an Instance Profile")
    ]
    tests += prod_tests
else:
    dev_tests = [
        lambda: Test.test(Func.dev_instance_running, "Confirm that the Development EC2 Instance is Running"),
        lambda: Test.test(Func.dev_instance_not_overscaled, "Ensure there are an Expected Number of Instances"),
        lambda: Test.test(Func.dev_instance_profile_exists, "Ensure the EC2 Instance has an Instance Profile")
    ]
    tests += dev_tests


def webserver_test_suite() -> bool:
    """
    Execute all the tests related to the Web Server and Launch Configuration
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "WebApp Test Suite")
