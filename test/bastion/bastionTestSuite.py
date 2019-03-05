"""
Test suite for the Bastion host.  Runs all the unit tests.
Author: Andrew Jarombek
Date: 2/23/2019
"""

import masterTestFuncs as Test
from bastion import bastionTestFuncs as Func

tests = [
    lambda: Test.test(Func.bastion_ec2_running, "Bastion EC2 Instance Running"),
    lambda: Test.test(Func.bastion_vpc, "Bastion VPC is SaintsXCTFcom"),
    lambda: Test.test(Func.bastion_subnet, "Bastion Subnet is SaintsXCTFcom Public 1"),
    lambda: Test.test(Func.bastion_rds_access, "Bastion has rds-access-role IAM Role"),
    lambda: Test.test(Func.bastion_security_group, "Bastion Security Group is bastion-security")
]


def bastion_test_suite() -> bool:
    """
    Execute all the tests related to the Bastion host
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "Bastion Test Suite")
