"""
Functions which represent Unit tests for the RDS instances and database backups
Author: Andrew Jarombek
Date: 3/5/2019
"""

import unittest
import os

import boto3

try:
    prod_env = os.environ['TEST_ENV'] == "prod"
except KeyError:
    prod_env = True


class TestDatabase(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.rds = boto3.client('rds')
        self.ec2 = boto3.resource('ec2')
        self.s3 = boto3.client('s3')

        # Get the infrastructure environment to test (from an environment variable)
        self.prod_env = prod_env

        if self.prod_env:
            self.rds_instance = self.get_rds('saints-xctf-mysql-database-prod')
        else:
            self.rds_instance = self.get_rds('saints-xctf-mysql-database-dev')

    def get_rds(self, db_id: str) -> dict:
        """
        Retrieve an RDS instance with a specific ID from AWS
        :param db_id: The identifier (name) of the RDS instance
        :return: An object representing metadata about an RDS database
        """
        prod_db_result = self.rds.describe_db_instances(DBInstanceIdentifier=db_id)
        return prod_db_result.get('DBInstances')[0]

    @unittest.skipIf(not prod_env, 'Development RDS instance not running.')
    def test_rds_running(self) -> None:
        """
        Make sure that an RDS instance is running
        """
        status = self.rds_instance.get('DBInstanceStatus')
        self.assertTrue(status == 'available')

    @unittest.skipIf(not prod_env, 'Development RDS instance not running.')
    def test_rds_engine_as_expected(self) -> None:
        """
        Determine if the engine and version of an RDS database is as expected
        """
        rds_engine = self.rds_instance.get('Engine')
        rds_version = self.rds_instance.get('EngineVersion')
        self.assertEqual(rds_engine, 'mysql')
        self.assertEqual(rds_version, '5.7.33')

    @unittest.skipIf(not prod_env, 'Development RDS instance not running.')
    def test_rds_in_proper_subnets(self) -> None:
        """
        Confirm that RDS is highly available across multiple subnets
        """
        filters = [
            {
                'Name': 'tag:Name',
                'Values': ['saints-xctf-com-cassiah-private-subnet', 'saints-xctf-com-carolined-private-subnet']
            }
        ]

        subnets = list(self.ec2.subnets.filter(Filters=filters))
        subnets = [subnets[0].id, subnets[1].id]

        rds_subnets_data = self.rds_instance.get('DBSubnetGroup').get('Subnets')

        rds_subnets = []
        for subnet in rds_subnets_data:
            rds_subnets.append(subnet.get('SubnetIdentifier'))

        self.assertTrue(len(subnets) == len(rds_subnets))
        self.assertTrue(all((rds_subnet in subnets) for rds_subnet in rds_subnets))

    @unittest.skipIf(not prod_env, 'S3 database backup not setup in development.')
    def test_s3_backup_bucket_exists(self) -> None:
        """
        Test if an S3 bucket for database backups exists
        """
        if self.prod_env:
            bucket_name = 'saints-xctf-db-backups-prod'
        else:
            bucket_name = 'saints-xctf-db-backups-dev'

        s3_bucket = self.s3.list_objects(Bucket=bucket_name)
        self.assertTrue(s3_bucket.get('Name') == bucket_name)
