"""
Author: Andrew Jarombek
Date: 2/23/2019
"""

import masterTestFuncs as Test
from bastion import bastionTestFuncs as Func

tests = [
    lambda: Test.test(Func.bastionec2running, "Bastion EC2 Instance Running")
]


def bastiontestsuite() -> bool:
    """
    Execute all the tests related to the Bastion host
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "Bastion Test Suite")
