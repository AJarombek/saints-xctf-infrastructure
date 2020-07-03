"""
Functions which represent Unit tests for the web server and launch configuration
Author: Andrew Jarombek
Date: 3/17/2019
"""

import unittest
import os

import boto3

try:
    prod_env = os.environ['TEST_ENV'] == "prod"
except KeyError:
    prod_env = True


class TestWebServer(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.ec2 = boto3.resource('ec2')
        self.ec2_client = boto3.client('ec2')
        self.sts = boto3.client('sts')
        self.iam = boto3.client('iam')
        self.autoscaling = boto3.client('autoscaling')

        self.prod_env = prod_env

    def test_ami_exists(self) -> None:
        """
        Check if there are one or many AMIs for the SaintsXCTF web server.
        """
        owner = self.sts.get_caller_identity().get('Account')
        amis = self.ec2_client.describe_images(
            Owners=[owner],
            Filters=[{
                'Name': 'name',
                'Values': ['saints-xctf-web-server*']
            }]
        )
        self.assertTrue(len(amis.get('Images')) > 0)

    @unittest.skipIf(prod_env == 'dev', 'Web server not running in development.')
    def test_instance_running(self) -> None:
        """
        Validate that the EC2 instance(s) holding the production web server are running
        """
        if self.prod_env:
            ec2_name = 'saints-xctf-server-prod-asg'
        else:
            ec2_name = 'saints-xctf-server-dev-asg'

        instances = self.get_ec2(ec2_name)
        self.assertTrue(len(instances) > 0)

    def test_instance_not_overscaled(self) -> None:
        """
        Ensure that there aren't too many EC2 instances running for the production web server
        """
        if self.prod_env:
            ec2_name = 'saints-xctf-server-prod-asg'
        else:
            ec2_name = 'saints-xctf-server-dev-asg'

        instances = self.get_ec2(ec2_name)
        self.assertTrue(len(instances) < 3)

    @unittest.skipIf(prod_env == 'dev', 'No instance profile setup in development.')
    def test_instance_profile_exists(self) -> None:
        """
        Prove that the instance profile exists for the prod EC2 web server
        """
        self.assertTrue(self.validate_instance_profile('s3-access-role', is_prod=self.prod_env))

    @unittest.skipIf(prod_env == 'dev', 'No launch configuration setup in development.')
    def test_launch_config_valid(self) -> None:
        """
        Ensure that the Launch Configuration for a SaintsXCTF web server in production is valid
        """
        if self.prod_env:
            ec2_name = 'saints-xctf-server-prod-asg'
            launch_config_name = 'saints-xctf-server-prod-lc'
            instance_profile = 'saints-xctf-prod-instance-profile'
        else:
            ec2_name = 'saints-xctf-server-dev-asg'
            launch_config_name = 'saints-xctf-server-dev-lc'
            instance_profile = 'saints-xctf-dev-instance-profile'

        instance = self.get_ec2(ec2_name)[0]
        security_group = instance.security_groups[0]

        lcs = self.autoscaling.describe_launch_configurations(
            LaunchConfigurationNames=[launch_config_name],
            MaxRecords=1
        )

        launch_config = lcs.get('LaunchConfigurations')[0]

        self.assertTrue(all([
            launch_config.get('InstanceType') == 't2.micro',
            launch_config.get('KeyName') == 'saints-xctf-key',
            len(launch_config.get('SecurityGroups')) == 1,
            launch_config.get('SecurityGroups')[0] == security_group.get('GroupId'),
            launch_config.get('IamInstanceProfile') == instance_profile
        ]))

    @unittest.skipIf(prod_env == 'dev', 'No launch configuration setup in development.')
    def test_launch_config_sg_valid(self):
        """
        Ensure that the security group attached to the launch configuration is as expected
        """
        if self.prod_env:
            launch_config_name = 'saints-xctf-server-prod-lc'
            launch_config_sg = 'saints-xctf-prod-server-lc-security-group'
        else:
            launch_config_name = 'saints-xctf-server-dev-lc'
            launch_config_sg = 'saints-xctf-dev-server-lc-security-group'

        lcs = self.autoscaling.describe_launch_configurations(
            LaunchConfigurationNames=[launch_config_name],
            MaxRecords=1
        )

        launch_config = lcs.get('LaunchConfigurations')[0]
        security_group_id = launch_config.get('SecurityGroups')[0]

        security_group = self.ec2_client.describe_security_groups(GroupIds=[security_group_id]).get('SecurityGroups')[0]

        self.assertTrue(all([
            security_group.get('GroupName') == launch_config_sg,
            self.validate_launch_config_sg_rules(
                security_group.get('IpPermissions'),
                security_group.get('IpPermissionsEgress')
            )
        ]))

    @unittest.skipIf(prod_env == 'dev', 'No auto scaling group setup in development.')
    def test_autoscaling_group_valid(self) -> None:
        """
        Ensure that the AutoScaling Group for a SaintsXCTF web server in production is valid
        """
        self.assertTrue(self.validate_autoscaling_group(is_prod=self.prod_env))

    @unittest.skipIf(prod_env == 'dev', 'No auto scaling group setup in development.')
    def test_autoscaling_schedules_unset(self) -> None:
        """
        Make sure there are no autoscaling schedules in production (the ASG should always be up)
        """
        if self.prod_env:
            schedules = self.autoscaling.describe_scheduled_actions(AutoScalingGroupName='saints-xctf-server-prod-asg')
            self.assertTrue(len(schedules.get('ScheduledUpdateGroupActions')) == 0)
        else:
            self.assertTrue(all([
                self.validate_autoscaling_schedule('saints-xctf-server-online-weekday-morning',
                                                   recurrence='30 11 * * 1-5', max_size=1, min_size=1, desired_size=1),
                self.validate_autoscaling_schedule('saints-xctf-server-offline-weekday-morning',
                                                   recurrence='30 13 * * 1-5', max_size=0, min_size=0, desired_size=0),
                self.validate_autoscaling_schedule('saints-xctf-server-online-weekday-afternoon',
                                                   recurrence='30 22 * * 1-5', max_size=1, min_size=1, desired_size=1),
                self.validate_autoscaling_schedule('saints-xctf-server-offline-weekday-night',
                                                   recurrence='30 3 * * 2-6', max_size=0, min_size=0, desired_size=0),
                self.validate_autoscaling_schedule('saints-xctf-server-online-weekend', recurrence='30 11 * * 0,6',
                                                   max_size=1, min_size=1, desired_size=1),
                self.validate_autoscaling_schedule('saints-xctf-server-offline-weekend', recurrence='30 3 * * 0,1',
                                                   max_size=0, min_size=0, desired_size=0)
            ]))

    def prod_load_balancer_running(self) -> None:
        """
        Prove that the application load balancer in production is running
        """
        self.assertTrue(self.validate_load_balancer(is_prod=self.prod_env))

    def prod_load_balancer_sg_valid(self) -> None:
        """
        Ensure that the security group attached to the load balancer is as expected
        """
        if self.prod_env:
            sg_name = 'saints-xctf-prod-server-elb-security-group'
        else:
            sg_name = 'saints-xctf-dev-server-elb-security-group'

        response = self.ec2.describe_security_groups(Filters=[
            {
                'Name': 'group-name',
                'Values': [sg_name]
            }
        ])

        security_group = response.get('SecurityGroups')[0]

        self.assertTrue(all([
            security_group.get('GroupName') == sg_name,
            self.validate_load_balancer_sg_rules(
                security_group.get('IpPermissions'),
                security_group.get('IpPermissionsEgress')
            )
        ]))

    """
    Helper functions to use for retrieving EC2 information
    """

    def get_ec2(self, name: str) -> list:
        """
        Get a list of running EC2 instances with a given name
        :param name: The name of EC2 instances to retrieve
        :return: A list of EC2 instances
        """
        filters = [
            {
                'Name': 'tag:Name',
                'Values': [name]
            },
            {
                'Name': 'instance-state-name',
                'Values': ['running']
            }
        ]

        return list(self.ec2.instances.filter(Filters=filters).all())

    def validate_instance_profile(self, role_name: str, is_prod: bool = True):
        """
        Validate that the instance profile for an EC2 instance contains the expected role
        :param role_name: Role expected on the EC2 instance
        :param is_prod: Whether the EC2 instance is in production environment or not
        :return: True if the instance profile role is as expected, False otherwise
        """
        if is_prod:
            env = "prod"
        else:
            env = "dev"

        # First get the instance profile resource name from the ec2 instance
        instances = self.get_ec2(f'saints-xctf-server-{env}-asg')
        instance_profile_arn = instances[0].iam_instance_profile.get('Arn')

        # Second get the instance profile from IAM
        instance_profile = self.iam.get_instance_profile(InstanceProfileName=f'saints-xctf-{env}-instance-profile')
        instance_profile = instance_profile.get('InstanceProfile')

        # Third get the RDS access IAM Role resource name from IAM
        role = self.iam.get_role(RoleName=role_name)
        role_arn = role.get('Role').get('Arn')

        return all([
            instance_profile_arn == instance_profile.get('Arn'),
            role_arn == instance_profile.get('Roles')[0].get('Arn')
        ])

    def validate_autoscaling_group(self, is_prod: bool = True) -> bool:
        """
        Ensure that the AutoScaling Group for a SaintsXCTF web server in a given environment is valid
        :param is_prod: Whether the EC2 instance is in production environment or not
        :return: True if its valid, False otherwise
        """
        if is_prod:
            env = "prod"
        else:
            env = "dev"

        asgs = self.autoscaling.describe_auto_scaling_groups(
            AutoScalingGroupNames=[f'saints-xctf-server-{env}-asg'],
            MaxRecords=1
        )

        asg = asgs.get('AutoScalingGroups')[0]

        return all([
            asg.get('LaunchConfigurationName') == f'saints-xctf-server-{env}-lc',
            asg.get('MinSize') == 1,
            asg.get('MaxSize') == 1,
            asg.get('DesiredCapacity') == 1,
            len(asg.get('Instances')) == 1,
            asg.get('Instances')[0].get('LifecycleState') == 'InService',
            asg.get('Instances')[0].get('HealthStatus') == 'Healthy'
        ])

    def validate_autoscaling_schedule(self, name: str, recurrence: str = '', max_size: int = 0,
                                      min_size: int = 0, desired_size: int = 0) -> bool:
        """
        Make sure an autoscaling schedule exists as expected
        :param name: The name of the autoscaling schedule
        :param recurrence: When this schedule recurs
        :param max_size: maximum number of instances in the asg
        :param min_size: minimum number of instances in the asg
        :param desired_size: desired number of instances in the asg
        :return: True if the schedule exists as expected, False otherwise
        """
        response = self.autoscaling.describe_scheduled_actions(
            AutoScalingGroupName='saints-xctf-server-prod-asg',
            ScheduledActionNames=[name],
            MaxRecords=1
        )

        schedule = response.get('ScheduledUpdateGroupActions')[0]

        return all([
            schedule.get('Recurrence') == recurrence,
            schedule.get('MinSize') == min_size,
            schedule.get('MaxSize') == max_size,
            schedule.get('Recurrence') == desired_size
        ])

    def validate_load_balancer(self, is_prod: bool = True) -> bool:
        """
        Prove that an application load balancer is running by checking its target groups
        :param is_prod: Whether the load balancer is in production environment or not
        :return: True if its running, False otherwise
        """
        if is_prod:
            env = "prod"
        else:
            env = "dev"

        response = self.autoscaling.describe_load_balancer_target_groups(
            AutoScalingGroupName=f'saints-xctf-server-{env}-asg'
        )

        load_balancers = response.get('LoadBalancerTargetGroups')

        return all([
            len(load_balancers) == 2,
            load_balancers[0].get('State') == 'InService',
            'targetgroup/saints-xctf-lb-target-http' in load_balancers[0].get('LoadBalancerTargetGroupARN'),
            load_balancers[1].get('State') == 'InService',
            'targetgroup/saints-xctf-lb-target' in load_balancers[1].get('LoadBalancerTargetGroupARN'),
        ])

    def validate_load_balancer_sg_rules(self, ingress: list, egress: list, is_prod: bool = True) -> bool:
        """
        Ensure that the load balancers security group rules are as expected in a given environment
        :param ingress: Ingress rules for the security group
        :param egress: Egress rules for the security group
        :param is_prod: Whether the load balancer is in production environment or not
        :return: True if the security group rules exist as expected, False otherwise
        """
        if is_prod:
            env = "prod"
        else:
            env = "dev"

        response = self.ec2.describe_security_groups(Filters=[
            {
                'Name': 'group-name',
                'Values': [f'saints-xctf-database-security-{env}']
            }
        ])

        database_sg = response.get('SecurityGroups')[0]

        ingress_80 = self.validate_sg_rule_cidr(ingress[0], 'tcp', 80, 80, '0.0.0.0/0')
        ingress_22 = self.validate_sg_rule_cidr(ingress[1], 'tcp', 22, 22, '69.124.72.192/32')
        ingress_443 = self.validate_sg_rule_cidr(ingress[2], 'tcp', 443, 443, '0.0.0.0/0')

        egress_80 = self.validate_sg_rule_cidr(egress[0], 'tcp', 80, 80, '0.0.0.0/0')
        egress_neg1 = self.validate_sg_rule_cidr(egress[1], '-1', 0, 0, '0.0.0.0/0')
        egress_25 = self.validate_sg_rule_cidr(egress[2], 'tcp', 25, 25, '0.0.0.0/0')
        egress_3306 = self.validate_sg_rule_source(egress[3], 'tcp', 3306, 3306, database_sg.get('GroupId'))
        egress_443 = self.validate_sg_rule_cidr(egress[4], 'tcp', 443, 443, '0.0.0.0/0')

        return all([
            len(ingress) == 3,
            ingress_80,
            ingress_443,
            ingress_22,
            len(egress) == 5,
            egress_80,
            egress_25,
            egress_neg1,
            egress_3306,
            egress_443
        ])

    def validate_launch_config_sg_rules(self, ingress: list, egress: list, is_prod: bool = True) -> bool:
        """
        Ensure that the launch configurations security group rules are as expected in a given environment
        :param ingress: Ingress rules for the security group
        :param egress: Egress rules for the security group
        :param is_prod: Whether the launch configuration is in production environment or not
        :return: True if the security group rules exist as expected, False otherwise
        """
        if is_prod:
            env = "prod"
        else:
            env = "dev"

        response = self.ec2_client.describe_security_groups(Filters=[
            {
                'Name': 'group-name',
                'Values': [f'saints-xctf-database-security-{env}']
            }
        ])

        database_sg = response.get('SecurityGroups')[0]

        ingress_80 = self.validate_sg_rule_cidr(ingress[0], 'tcp', 80, 80, '0.0.0.0/0')
        ingress_443 = self.validate_sg_rule_cidr(ingress[2], 'tcp', 443, 443, '0.0.0.0/0')
        ingress_22 = self.validate_sg_rule_cidr(ingress[1], 'tcp', 22, 22, '69.124.72.192/32')

        egress_80 = self.validate_sg_rule_cidr(egress[0], 'tcp', 80, 80, '0.0.0.0/0')
        egress_25 = self.validate_sg_rule_cidr(egress[1], 'tcp', 25, 25, '0.0.0.0/0')
        egress_3306 = self.validate_sg_rule_source(egress[2], 'tcp', 3306, 3306, database_sg.get('GroupId'))
        egress_443 = self.validate_sg_rule_cidr(egress[3], 'tcp', 443, 443, '0.0.0.0/0')

        return all([
            len(ingress) == 3,
            ingress_80,
            ingress_443,
            ingress_22,
            len(egress) == 4,
            egress_80,
            egress_25,
            egress_3306,
            egress_443
        ])

    def validate_sg_rule_cidr(self, rule: dict, protocol: str, from_port: int, to_port: int, cidr: str) -> bool:
        """
        Determine if a security group rule which opens connections
        from (ingress) or to (egress) a CIDR block exists as expected.
        :param rule: A dictionary containing security group rule information
        :param protocol: Which protocol the rule enables connections for
        :param from_port: Which source port the rule enables connections for
        :param to_port: Which destination port the rule enables connections for
        :param cidr: The ingress or egress CIDR block
        :return: True if the security group rule exists as expected, False otherwise
        """
        if from_port == 0:
            from_port_valid = 'FromPort' not in rule.keys()
        else:
            from_port_valid = rule.get('FromPort') == from_port

        if to_port == 0:
            to_port_valid = 'ToPort' not in rule.keys()
        else:
            to_port_valid = rule.get('ToPort') == to_port

        return all([
            rule.get('IpProtocol') == protocol,
            from_port_valid,
            to_port_valid,
            rule.get('IpRanges')[0].get('CidrIp') == cidr
        ])

    def validate_sg_rule_source(self, rule: dict, protocol: str, from_port: int, to_port: int, source_sg: str) -> bool:
        """
        Determine if a security group rule which opens connections
        from a different source security group exists as expected.
        :param rule: A dictionary containing security group rule information
        :param protocol: Which protocol the rule enables connections for
        :param from_port: Which source port the rule enables connections for
        :param to_port: Which destination port the rule enables connections for
        :param source_sg: The destination security group identifier
        :return: True if the security group rule exists as expected, False otherwise
        """
        return all([
            rule.get('IpProtocol') == protocol,
            rule.get('FromPort') == from_port,
            rule.get('ToPort') == to_port,
            rule.get('UserIdGroupPairs')[0].get('GroupId') == source_sg
        ])
