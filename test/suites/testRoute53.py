"""
Functions which represent Unit tests for Route53 records and zones
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


class TestRoute53(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.route53 = boto3.client('route53')
        self.prod_env = prod_env

    def test_saintsxctf_zone_exists(self) -> None:
        """
        Determine if the saintsxctf.com Route53 zone exists.
        """
        zones = self.route53.list_hosted_zones_by_name(DNSName='saintsxctf.com.', MaxItems='1').get('HostedZones')
        self.assertTrue(len(zones) == 1)

    def test_saintsxctf_zone_public(self) -> None:
        """
        Determine if the saintsxctf.com Route53 zone is public.
        """
        zones = self.route53.list_hosted_zones_by_name(DNSName='saintsxctf.com.', MaxItems='1').get('HostedZones')
        self.assertTrue(zones[0].get('Config').get('PrivateZone') is False)

    def test_saintsxctf_ns_record_exists(self) -> None:
        """
        Determine if the 'NS' record exists for 'saintsxctf.com.' in Route53
        """
        a_record = self.get_record('saintsxctf.com.', 'saintsxctf.com.', 'NS')
        self.assertTrue(a_record.get('Name') == 'saintsxctf.com.' and a_record.get('Type') == 'NS')

    @unittest.skipIf(prod_env == 'dev', 'A record not configured in development.')
    def test_saintsxctf_a_record_exists(self) -> None:
        """
        Determine if the 'A' record exists for 'saintsxctf.com.' in Route53
        """
        if self.prod_env:
            record_name = 'saintsxctf.com.'
        else:
            record_name = 'dev.saintsxctf.com.'

        a_record = self.get_record('saintsxctf.com.', record_name, 'A')
        self.assertTrue(a_record.get('Name') == 'saintsxctf.com.' and a_record.get('Type') == 'A')

    @unittest.skipIf(prod_env == 'dev', 'A record not configured in development.')
    def test_www_saintsxctf_a_record_exists(self) -> None:
        """
        Determine if the 'A' record exists for 'www.saintsxctf.com.' in Route53
        """
        if self.prod_env:
            record_name = 'www.saintsxctf.com.'
        else:
            record_name = 'www.dev.saintsxctf.com.'

        a_record = self.get_record('saintsxctf.com.', record_name, 'A')
        self.assertTrue(a_record.get('Name') == 'www.saintsxctf.com.' and a_record.get('Type') == 'A')

    def get_record(self, zone_name: str, record_name: str, record_type: str) -> dict:
        """
        Helper method which gets Route53 record information.
        :param zone_name: the DNS name of a Hosted Zone the record exists in
        :param record_name: the name of the Route53 record to retrieve information about
        :param record_type: the type of the Route53 record to retrieve information about
        :return: A dictionary containing information about the Route53 record
        """
        hosted_zone_id = self.get_hosted_zone_id(zone_name)
        record_sets = self.route53.list_resource_record_sets(
            HostedZoneId=hosted_zone_id,
            StartRecordName=record_name,
            StartRecordType=record_type,
            MaxItems='1'
        )
        return record_sets.get('ResourceRecordSets')[0]

    def get_hosted_zone_id(self, name: str) -> str:
        """
        Helper function to get a Hosted Zone ID based off its name
        :param name: The DNS name of the Hosted Zone
        :return: A string representing the Hosted Zone ID
        """
        hosted_zone = self.route53.list_hosted_zones_by_name(DNSName=name, MaxItems='1').get('HostedZones')[0]
        return hosted_zone.get('Id')
