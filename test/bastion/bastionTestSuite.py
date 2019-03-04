"""
Author: Andrew Jarombek
Date: 2/23/2019
"""

import masterTestFuncs as Test
from bastion import bastionTestFuncs as Func

tests = [
    lambda: Test.test(Func.bastion_ec2_running, "Bastion EC2 Instance Running"),
    lambda: Test.test(Func.bastion_vpc, "Bastion VPC is SaintsXCTFcom"),
    lambda: Test.test(Func.bastion_subnet, "Bastion Subnet is SaintsXCTFcom Public 1"),
    lambda: Test.test(Func.bastion_rds_access, "Bastion has rds-access-role IAM role"),
    lambda: Test.test(Func.bastion_security_group, "Bastion Security Group is bastion-security")
]


def bastiontestsuite() -> bool:
    """
    Execute all the tests related to the Bastion host
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "Bastion Test Suite")
