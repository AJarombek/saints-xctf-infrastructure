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
    prod_env = True

tests = [
    lambda: Test.test(Func.ami_exists, "Confirm one or more AMIs Exist for SaintsXCTF")
]

if prod_env:
    prod_tests = [
        lambda: Test.test(Func.prod_instance_running, "Confirm that the Production EC2 Instance is Running"),
        lambda: Test.test(Func.prod_instance_not_overscaled, "Ensure there are an Expected Number of Instances"),
        lambda: Test.test(Func.prod_instance_profile_exists, "Ensure the EC2 Instance has an Instance Profile"),
        lambda: Test.test(Func.prod_launch_config_valid, "Validate the EC2 Launch Configuration"),
        lambda: Test.test(Func.prod_autoscaling_group_valid, "Validate the EC2 AutoScaling Group"),
        lambda: Test.test(Func.prod_autoscaling_schedules_unset, "Ensure the EC2 AutoScaling Group has no Schedules"),
        lambda: Test.test(Func.prod_load_balancer_running, "Validate the Web Server Load Balancer is Running"),
        lambda: Test.test(Func.prod_launch_config_sg_valid, "Validate the Launch Configurations Security Groups"),
        lambda: Test.test(Func.prod_load_balancer_sg_valid, "Validate the Load Balancers Security Groups")
    ]
    tests += prod_tests
else:
    dev_tests = [
        lambda: Test.test(Func.dev_instance_running, "Confirm that the Development EC2 Instance is Running"),
        lambda: Test.test(Func.dev_instance_not_overscaled, "Ensure there are an Expected Number of Instances"),
        lambda: Test.test(Func.dev_instance_profile_exists, "Ensure the EC2 Instance has an Instance Profile"),
        lambda: Test.test(Func.dev_launch_config_valid, "Validate the EC2 Launch Configuration"),
        lambda: Test.test(Func.dev_autoscaling_group_valid, "Validate the EC2 AutoScaling Group"),
        lambda: Test.test(Func.dev_autoscaling_schedules_set, "Ensure the EC2 AutoScaling Group has Schedules"),
        lambda: Test.test(Func.dev_load_balancer_running, "Validate the Web Server Load Balancer is Running"),
        lambda: Test.test(Func.dev_launch_config_sg_valid, "Validate the Launch Configurations Security Groups"),
        lambda: Test.test(Func.dev_load_balancer_sg_valid, "Validate the Load Balancers Security Groups")
    ]
    tests += dev_tests


def webserver_test_suite() -> bool:
    """
    Execute all the tests related to the Web Server and Launch Configuration
    :return: True if the tests succeed, False otherwise
    """
    return Test.testsuite(tests, "WebApp Test Suite")
