"""
Functions which represent Unit tests for the RDS instances and database backups
Author: Andrew Jarombek
Date: 3/5/2019
"""

import boto3

rds = boto3.client('rds')

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


def rds_running(instance: map) -> bool:
    """
    Make sure that an RDS instance is running
    :param instance: Metadata about a database instance (retrieved from AWS)
    :return: True if the database instance is running, False otherwise
    """
    status = instance.get('DBInstanceStatus')
    return status == 'available'


def rds_engine_as_expected(instance: map, engine: str, version: str) -> bool:
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


def rds_in_proper_subnets(instance: map, subnets: list):
    """
    Confirm that RDS is highly available across multiple subnets
    :param instance: Metadata about a database instance (retrieved from AWS)
    :param subnets: A list of subnet ids the instance should be in
    :return: True if the subnet list matches the ones on AWS RDS, False otherwise
    """
    pass


"""
The RDS instances to use in Unit tests
"""

rds_dev = get_rds('saints-xctf-mysql-database-dev')
rds_prod = get_rds('saints-xctf-mysql-database-prod')

"""
Tests for the SaintsXCTF Production MySQL Database
"""


def rds_prod_running() -> bool:
    """
    Make sure that the production SaintsXCTF RDS instance is running
    :return: True if the database instance is running, False otherwise
    """
    return rds_running(rds_prod)


def rds_prod_engine_as_expected() -> bool:
    return rds_engine_as_expected(rds_prod, 'mysql', '5.7.19')


def rds_prod_in_proper_subnets():
    rds_in_proper_subnets(rds_prod, [])


"""
Tests for the SaintsXCTF Development MySQL Database
"""


def rds_dev_running() -> bool:
    """
    Make sure that the development SaintsXCTF RDS instance is running
    :return: True if the database instance is running, False otherwise
    """
    return rds_running(rds_dev)


def rds_dev_engine_as_expected() -> bool:
    return rds_engine_as_expected(rds_dev, 'mysql', '5.7.19')


def rds_dev_in_proper_subnets():
    rds_in_proper_subnets(rds_dev, [])
