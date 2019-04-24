"""
Functions which represent Unit tests for Route53 records and zones
Author: Andrew Jarombek
Date: 3/17/2019
"""

import boto3

route53 = boto3.client('route53')

"""
Tests for all environments
"""


def saintsxctf_zone_exists() -> bool:
    """
    Determine if the saintsxctf.com Route53 zone exists.
    :return: True if it exists, False otherwise
    """
    zones = route53.list_hosted_zones_by_name(DNSName='saintsxctf.com.', MaxItems='1').get('HostedZones')
    return len(zones) == 1


def saintsxctf_zone_public() -> bool:
    """
    Determine if the saintsxctf.com Route53 zone is public.
    :return: True if its public, False otherwise
    """
    zones = route53.list_hosted_zones_by_name(DNSName='saintsxctf.com.', MaxItems='1').get('HostedZones')
    return zones[0].get('Config').get('PrivateZone') is False


def saintsxctf_a_record_exists() -> bool:
    """
    Determine if the 'A' record exists for 'saintsxctf.com.' in Route53
    :return: True if it exists, False otherwise
    """
    a_record = get_record('saintsxctf.com.', 'saintsxctf.com.', 'A')
    return a_record.get('Name') == 'saintsxctf.com.' and a_record.get('Type') == 'A'


def www_saintsxctf_a_record_exists() -> bool:
    """
    Determine if the 'A' record exists for 'www.saintsxctf.com.' in Route53
    :return: True if it exists, False otherwise
    """
    a_record = get_record('saintsxctf.com.', 'www.saintsxctf.com.', 'A')
    return a_record.get('Name') == 'www.saintsxctf.com.' and a_record.get('Type') == 'A'


"""
Helper functions to use for retrieving Route53 information
"""


def get_record(zone_name: str, record_name: str, record_type: str) -> dict:
    """
    Helper method which gets Route53 record information.
    :param zone_name: the DNS name of a Hosted Zone the record exists in
    :param record_name: the name of the Route53 record to retrieve information about
    :param record_type: the type of the Route53 record to retrieve information about
    :return: A dictionary containing information about the Route53 record
    """
    hosted_zone_id = get_hosted_zone_id(zone_name)
    record_sets = route53.list_resource_record_sets(
        HostedZoneId=hosted_zone_id,
        StartRecordName=record_name,
        StartRecordType=record_type,
        MaxItems='1'
    )
    return record_sets.get('ResourceRecordSets')[0]


def get_hosted_zone_id(name: str) -> str:
    """
    Helper function to get a Hosted Zone ID based off its name
    :param name: The DNS name of the Hosted Zone
    :return: A string representing the Hosted Zone ID
    """
    hosted_zone = route53.list_hosted_zones_by_name(DNSName=name, MaxItems='1').get('HostedZones')[0]
    return hosted_zone.get('Id')
