"""
Functions which represent Unit tests for the RDS instances and database backups
Author: Andrew Jarombek
Date: 3/5/2019
"""

import boto3
import os

rds = boto3.client('rds')
ec2 = boto3.resource('ec2')
s3 = boto3.client('s3')

# Get the infrastructure environment to test (from an environment variable)
try:
    prod_env = os.environ['TEST_ENV'] == "prod"
except KeyError:
    prod_env = True

"""
Generic functions to use for any RDS instance
"""


def get_rds(db_id: str) -> dict:
    """
    Retrieve an RDS instance with a specific ID from AWS
    :param db_id: The identifier (name) of the RDS instance
    :return: An object representing metadata about an RDS database
    """
    prod_db_result = rds.describe_db_instances(DBInstanceIdentifier=db_id)
    return prod_db_result.get('DBInstances')[0]


def _rds_running(instance: map) -> bool:
    """
    Make sure that an RDS instance is running
    :param instance: Metadata about a database instance (retrieved from AWS)
    :return: True if the database instance is running, False otherwise
    """
    status = instance.get('DBInstanceStatus')
    return status == 'available'


def _rds_engine_as_expected(instance: map, engine: str, version: str) -> bool:
    """
    Determine if the engine and version of an RDS database is as expected
    :param instance: Metadata about a database instance (retrieved from AWS)
    :param engine: Database engine used (mysql, oracle, postgresql, etc.)
    :param version: Database engine version
    :return: True if the database exists as expected, False otherwise
    """
    rds_engine = instance.get('Engine')
    rds_version = instance.get('EngineVersion')
    return rds_engine == engine and rds_version == version


def _rds_in_proper_subnets(instance: map, subnets: list):
    """
    Confirm that RDS is highly available across multiple subnets
    :param instance: Metadata about a database instance (retrieved from AWS)
    :param subnets: A list of subnet ids the instance should be in
    :return: True if the subnet list matches the ones on AWS RDS, False otherwise
    """
    rds_subnets_data = instance.get('DBSubnetGroup').get('Subnets')

    rds_subnets = []
    for subnet in rds_subnets_data:
        rds_subnets.append(subnet.get('SubnetIdentifier'))

    return len(subnets) == len(rds_subnets) and all((rds_subnet in subnets) for rds_subnet in rds_subnets)


def _s3_backup_bucket_exists(bucket_name: str):
    """
    Test if an S3 bucket for database backups exists
    :param bucket_name: the name of the S3 bucket
    :return: True if the bucket exists, False otherwise
    """
    s3_bucket = s3.list_objects(Bucket=bucket_name)
    return s3_bucket.get('Name') == bucket_name


"""
The RDS instances to use in Unit tests
"""

if prod_env:
    rds = get_rds('saints-xctf-mysql-database-prod')
else:
    rds = get_rds('saints-xctf-mysql-database-dev')

"""
Tests for the SaintsXCTF Production MySQL Database
"""


def rds_running() -> bool:
    """
    Make sure that a SaintsXCTF RDS instance is running
    :return: True if the database instance is running, False otherwise
    """
    return _rds_running(rds)


def rds_engine_as_expected() -> bool:
    """
    Confirm that a SaintsXCTF RDS instance is running the proper engine and version
    :return: True if the database exists as expected, False otherwise
    """
    return _rds_engine_as_expected(rds, 'mysql', '5.7.19')


def rds_in_proper_subnets():
    """
    Prove that a SaintsXCTF RDS instance is running HA in the proper subnets
    :return: True if the subnet list matches the ones on AWS RDS, False otherwise
    """
    filters = [
        {
            'Name': 'tag:Name',
            'Values': ['saints-xctf-com-cassiah-private-subnet', 'saints-xctf-com-carolined-private-subnet']
        }
    ]

    subnets = list(ec2.subnets.filter(Filters=filters))
    return _rds_in_proper_subnets(rds, [subnets[0].id, subnets[1].id])


def s3_backup_bucket_exists():
    """
    Confirm that a SaintsXCTF RDS instance has an S3 bucket for database backups
    :return: True if the bucket exists, False otherwise
    """
    if prod_env:
        return _s3_backup_bucket_exists('saints-xctf-db-backups-prod')
    else:
        return _s3_backup_bucket_exists('saints-xctf-db-backups-dev')
