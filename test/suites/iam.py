"""
Functions which represent Unit tests for IAM roles and policies
Author: Andrew Jarombek
Date: 3/17/2019
"""

import unittest
import boto3


class TestIAM(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.iam = boto3.client('iam')

    def rds_access_role_exists(self) -> None:
        """
        Test that the rds-access-role IAM Role exists
        :return: True if the IAM role exists, False otherwise
        """
        role_dict = self.iam.get_role(RoleName='rds-access-role')
        role = role_dict.get('Role')
        self.assertTrue(role.get('Path') == '/saintsxctf/' and role.get('RoleName') == 'rds-access-role')

    def s3_access_role_exists(self) -> None:
        """
        Test that the s3-access-role IAM Role exists
        :return: True if the IAM role exists, False otherwise
        """
        role_dict = self.iam.get_role(RoleName='s3-access-role')
        role = role_dict.get('Role')
        self.assertTrue(role.get('Path') == '/saintsxctf/' and role.get('RoleName') == 's3-access-role')

    def rds_access_policy_attached(self) -> None:
        """
        Test that the rds-access-policy is attached to the rds-access-role
        :return: True if the policy is attached to the role, False otherwise
        """
        policy_response = self.iam.list_attached_role_policies(RoleName='rds-access-role')
        policies = policy_response.get('AttachedPolicies')
        rds_policy = policies[0]
        self.assertTrue(len(policies) == 1 and rds_policy.get('PolicyName') == 'rds-access-policy')

    def s3_access_policy_attached(self) -> None:
        """
        Test that the s3-access-policy is attached to the s3-access-role
        :return: True if the policy is attached to the role, False otherwise
        """
        policy_response = self.iam.list_attached_role_policies(RoleName='s3-access-role')
        policies = policy_response.get('AttachedPolicies')
        s3_policy = policies[0]
        self.assertTrue(len(policies) == 1 and s3_policy.get('PolicyName') == 's3-access-policy')
