"""
Functions which represent Unit tests for the RDS instances and database backups
Author: Andrew Jarombek
Date: 3/5/2019
"""

import boto3

rds = boto3.client('rds')


def get_rds(db_id: str) -> dict:
    prod_db_result = rds.describe_db_instances(DBInstanceIdentifier=db_id)
    return prod_db_result.get('DBInstances')[0]


rds_dev = get_rds('saints-xctf-mysql-database-dev')
rds_prod = get_rds('saints-xctf-mysql-database-prod')


def rds_prod_running() -> bool:
    pass


def rds_dev_running() -> bool:
    pass