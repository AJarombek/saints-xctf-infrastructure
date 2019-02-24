"""
Author: Andrew Jarombek
Date: 2/23/2019
"""

from .. import masterTestFuncs as Test
from . import bastionTestFuncs as Func

tests = [
    (Func.bastionec2running, "Bastion EC2 Instance Running")
]


def bastiontestsuite() -> bool:
    """
    Execute all the tests related to the Bastion host
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "Bastion Test Suite")
