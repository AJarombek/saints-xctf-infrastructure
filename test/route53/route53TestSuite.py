"""
Test suite for the Route53 records and zones.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 3/17/2019
"""

import masterTestFuncs as Test
from route53 import route53TestFuncs as Func

tests = [
    lambda: Test.test(Func.saintsxctf_zone_exists, "Check if the saintsxctf.com Hosted Zone Exists in Route53"),
    lambda: Test.test(Func.saintsxctf_zone_public, "Check if the saintsxctf.com Hosted Zone is Public"),
    lambda: Test.test(Func.saintsxctf_a_record_exists, "Check if the saintsxctf.com 'A' record exists"),
    lambda: Test.test(Func.www_saintsxctf_a_record_exists, "Check if the www.saintsxctf.com 'A' record exists")
]


def route53_test_suite() -> bool:
    """
    Execute all the tests related to Route53 records and zones
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "Route53 Test Suite")
