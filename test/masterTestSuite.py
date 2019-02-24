"""
Testing suite which calls all the more specific test suites
Author: Andrew Jarombek
Date: 2/23/2019
"""

import masterTestFuncs as Test
from bastion import bastionTestSuite as Bastion

# List of all the test suites
tests = [
    Bastion.bastiontestsuite
]

# Create and execute a master test suite
Test.testsuite(tests, "Master Test Suite")
