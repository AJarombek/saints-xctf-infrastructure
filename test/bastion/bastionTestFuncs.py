"""
Author: Andrew Jarombek
Date: 2/23/2019
"""

import boto3

ec2 = boto3.resource('ec2')
iam = boto3.client('iam')


def get_bastion_ec2() -> list:
    """
    Get a list of running EC2 instances with name 'bastion-host'
    :return: A list of EC2 instances
    """
    filters = [
        {
            'Name': 'tag:Name',
            'Values': ['bastion-host']
        },
        {
            'Name': 'instance-state-name',
            'Values': ['running']
        }
    ]

    return list(ec2.instances.filter(Filters=filters).all())


def bastion_ec2_running() -> bool:
    """
    Test that the Bastion EC2 instance is running
    :return: True if the instance is running, False otherwise
    """
    instances = get_bastion_ec2()
    return len(instances) == 1


def bastion_vpc() -> bool:
    """
    Test that the Bastion EC2 instance exists in the SaintsXCTF VPC
    :return: True if the VPC is as expected, False otherwise
    """
    instances = get_bastion_ec2()
    vpc = instances[0].vpc
    vpc_tag = vpc.tags[0]

    return vpc_tag == {'Key': 'Name', 'Value': 'SaintsXCTFcom VPC'}


def bastion_subnet() -> bool:
    """
    Test that the bastion EC2 instance is in the proper subnet
    :return: True if the subnet is the SaintsXCTFcom Public VPC 1, False otherwise
    """
    instances = get_bastion_ec2()
    subnet = instances[0].subnet
    subnet_tag = subnet.tags[0]

    return subnet_tag == {'Key': 'Name', 'Value': 'SaintsXCTFcom VPC Public Subnet 1'}


def bastion_rds_access() -> bool:
    """
    Confirm that the Bastion host has access to RDS
    :return: True if Bastion has an RDS role, False otherwise
    """

    # First get the instance profile resource name from the Bastion host
    instances = get_bastion_ec2()
    instance_profile_arn = instances[0].iam_instance_profile.get('Arn')

    # Second get the instance profile from IAM
    instance_profile = iam.get_instance_profile(InstanceProfileName='bastion-instance-profile').get('InstanceProfile')

    # Third get the RDS access IAM Role resource name from IAM
    role = iam.get_role(RoleName='rds-access-role')
    role_arn = role.get('Role').get('Arn')

    # Finally prove that the two instance profiles are equal, and the instance profile IAM role is rds-access-role
    return instance_profile_arn == instance_profile.get('Arn') and \
           role_arn == instance_profile.get('Roles')[0].get('Arn')


def bastion_security_group() -> bool:
    """
    Test that the Bastion host has the expected security group
    :return: True if the Bastion EC2 has the bastion-security security group, False otherwise
    """
    pass


print(bastion_rds_access())
