"""
Functions which represent Unit tests for the Bastion host infrastructure
Author: Andrew Jarombek
Date: 2/23/2019
"""

import unittest

import boto3


class TestBastion(unittest.TestCase):
    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.ec2 = boto3.resource("ec2")
        self.iam = boto3.client("iam")

    @unittest.SkipTest
    def get_bastion_ec2(self) -> list:
        """
        Get a list of running EC2 instances with name 'bastion-host'
        :return: A list of EC2 instances
        """
        filters = [
            {"Name": "tag:Name", "Values": ["bastion-host"]},
            {"Name": "instance-state-name", "Values": ["running"]},
        ]

        return list(self.ec2.instances.filter(Filters=filters).all())

    @unittest.SkipTest
    def test_bastion_ec2_running(self) -> None:
        """
        Test that the Bastion EC2 instance is running
        """
        instances = self.get_bastion_ec2()
        self.assertEqual(len(instances), 1)

    @unittest.SkipTest
    def test_bastion_vpc(self) -> None:
        """
        Test that the Bastion EC2 instance exists in the SaintsXCTF VPC
        """
        instances = self.get_bastion_ec2()

        if len(instances) == 0:
            self.assertTrue(False)

        vpc = instances[0].vpc
        vpc_tag = vpc.tags[0]

        self.assertEqual(vpc_tag, {"Key": "Name", "Value": "SaintsXCTFcom VPC"})

    @unittest.SkipTest
    def test_bastion_subnet(self) -> None:
        """
        Test that the bastion EC2 instance is in the proper subnet
        """
        instances = self.get_bastion_ec2()

        if len(instances) == 0:
            self.assertTrue(False)

        subnet = instances[0].subnet
        subnet_tag = subnet.tags[0]

        return subnet_tag == {
            "Key": "Name",
            "Value": "SaintsXCTFcom VPC Public Subnet 1",
        }

    @unittest.SkipTest
    def test_bastion_rds_access(self) -> None:
        """
        Confirm that the Bastion host has access to RDS
        """
        # First get the instance profile resource name from the Bastion host
        instances = self.get_bastion_ec2()

        if len(instances) == 0:
            self.assertTrue(False)

        instance_profile_arn = instances[0].iam_instance_profile.get("Arn")

        # Second get the instance profile from IAM
        instance_profile = self.iam.get_instance_profile(
            InstanceProfileName="bastion-instance-profile"
        ).get("InstanceProfile")

        # Third get the RDS access IAM Role resource name from IAM
        role = self.iam.get_role(RoleName="rds-access-role")
        role_arn = role.get("Role").get("Arn")

        # Finally prove that the two instance profiles are equal, and the instance profile IAM role is rds-access-role
        self.assertTrue(
            all(
                [
                    instance_profile_arn == instance_profile.get("Arn"),
                    role_arn == instance_profile.get("Roles")[0].get("Arn"),
                ]
            )
        )

    @unittest.SkipTest
    def test_bastion_security_group(self) -> None:
        """
        Test that the Bastion host has the expected security group
        """
        instances = self.get_bastion_ec2()

        if len(instances) == 0:
            self.assertTrue(False)

        security_group = instances[0].security_groups[0]
        self.assertEqual(security_group.get("GroupName"), "bastion-security")
