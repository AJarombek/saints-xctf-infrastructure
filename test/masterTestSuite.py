"""
Author: Andrew Jarombek
Date: 2/23/2019
"""

from . import masterTestFuncs as Test
from bastion import bastionTestSuite as Bastion

tests = [
    ()
]

Test.testsuite([Bastion.bastiontestsuite], "Master Test Suite")

