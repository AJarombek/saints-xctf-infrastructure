"""
Test suite for the ACM HTTPS certificates.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 3/4/2019
"""

import masterTestFuncs as Test
from acm import acmTestFuncs as Func

tests = [
    lambda: Test.test(Func.acm_dev_wildcard_cert_issued, "ACM SaintsXCTF Dev Wildcard Certificate Issued"),
    lambda: Test.test(Func.acm_wildcard_cert_issued, "ACM SaintsXCTF Wildcard Certificate Issued"),
    lambda: Test.test(Func.acm_cert_issued, "ACM SaintsXCTF Certificate Issued")
]


def acm_test_suite() -> bool:
    """
    Execute all the tests related to the ACM HTTPS certificates
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "ACM Test Suite")
