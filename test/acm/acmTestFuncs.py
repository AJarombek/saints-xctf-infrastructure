"""
Functions which represent Unit tests for the ACM HTTPS certificates and corresponding Route53 infrastructure
Author: Andrew Jarombek
Date: 3/4/2019
"""

import boto3

acm = boto3.client('acm')
acm_certificates = acm.list_certificates(CertificateStatuses=['ISSUED'])


def acm_dev_wildcard_cert_issued() -> bool:
    """
    Test that the dev wildcard ACM certificate exists
    :return: True if the VPC is as expected, False otherwise
    """
    for cert in acm_certificates.get('CertificateSummaryList'):
        if cert.get('DomainName') == '*.dev.saintsxctf.com':
            return True

    return False


def acm_wildcard_cert_issued() -> bool:
    """
    Test that the wildcard ACM certificate exists
    :return: True if the VPC is as expected, False otherwise
    """
    for cert in acm_certificates.get('CertificateSummaryList'):
        if cert.get('DomainName') == '*.saintsxctf.com':
            return True

    return False


def acm_cert_issued() -> bool:
    """
    Test that the main SaintsXCTF ACM certificate exists
    :return: True if the VPC is as expected, False otherwise
    """
    for cert in acm_certificates.get('CertificateSummaryList'):
        if cert.get('DomainName') == 'saintsxctf.com':
            return True

    return False
