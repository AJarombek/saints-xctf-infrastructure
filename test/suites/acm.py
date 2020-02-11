"""
Unit tests for the ACM HTTPS certificates and corresponding Route53 infrastructure
Author: Andrew Jarombek
Date: 3/4/2019
"""

import unittest
import boto3


class TestACM(unittest.TestCase):

    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.acm = boto3.client('acm')
        self.acm_certificates = self.acm.list_certificates(CertificateStatuses=['ISSUED'])

    def test_acm_dev_wildcard_cert_issued(self) -> None:
        """
        Test that the dev wildcard ACM certificate exists
        """
        for cert in self.acm_certificates.get('CertificateSummaryList'):
            if cert.get('DomainName') == '*.dev.saintsxctf.com':
                self.assertTrue(True)
                return

        self.assertTrue(False)

    def test_acm_wildcard_cert_issued(self) -> None:
        """
        Test that the wildcard ACM certificate exists
        """
        for cert in self.acm_certificates.get('CertificateSummaryList'):
            if cert.get('DomainName') == '*.saintsxctf.com':
                self.assertTrue(True)
                return

        self.assertTrue(False)

    def test_acm_cert_issued(self) -> None:
        """
        Test that the main SaintsXCTF ACM certificate exists
        """
        for cert in self.acm_certificates.get('CertificateSummaryList'):
            if cert.get('DomainName') == 'saintsxctf.com':
                self.assertTrue(True)
                return

        self.assertTrue(False)
