"""
Testing suite which calls all the more specific test suites
Author: Andrew Jarombek
Date: 2/23/2019
"""

import masterTestFuncs as Test
from bastion import bastionTestSuite as Bastion
from acm import acmTestSuite as ACM
from database import databaseTestSuite as Database
from iam import iamTestSuite as IAM
from route53 import route53TestSuite as Route53
from webapp import webappTestSuite as WebApp

# List of all the test suites
tests = [
    Bastion.bastion_test_suite,
    ACM.acm_test_suite,
    Database.database_test_suite,
    IAM.iam_test_suite,
    Route53.route53_test_suite,
    WebApp.webapp_test_suite
]

# Create and execute a master test suite
Test.testsuite(tests, "Master Test Suite")
