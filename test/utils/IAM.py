"""
Helper functions for AWS IAM roles and policies.
Author: Andrew Jarombek
Date: 9/19/2020
"""

import boto3
from boto3_type_annotations.iam import Client as IAMClient

iam: IAMClient = boto3.client('iam')


class IAM:

    @staticmethod
    def iam_role_exists(role_name: str) -> bool:
        """
        Test that an IAM Role exists
        :param role_name: Name of the IAM Role.
        """
        role_dict = iam.get_role(RoleName=role_name)
        role = role_dict.get('Role')
        return role.get('RoleName') == role_name

    @staticmethod
    def iam_policy_attached_to_role(role_name: str, policy_name: str) -> bool:
        """
        Test that an IAM policy is attached to an IAM role.
        :param role_name: Name of the IAM Role.
        :param policy_name: Name of the IAM Policy.
        """
        policy_response = iam.list_attached_role_policies(RoleName=role_name)
        policies = policy_response.get('AttachedPolicies')
        s3_policy = policies[0]

        return all([
            len(policies) == 1,
            s3_policy.get('PolicyName') == policy_name
        ])
