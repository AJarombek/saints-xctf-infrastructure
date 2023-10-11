"""
Unit tests for AWS CloudWatch Synthetic Monitoring canary functions.
Author: Andrew Jarombek
Date: 7/8/2021
"""

import unittest
import os
import json
from typing import Dict, Any, List

import boto3
from boto3_type_annotations.s3 import Client as S3Client
from boto3_type_annotations.sts import Client as STSClient
from boto3_type_annotations.events import Client as EventsClient

from aws_test_functions.IAM import IAM

try:
    prod_env = os.environ["TEST_ENV"] == "prod"
except KeyError:
    prod_env = True


class TestSyntheticMonitoring(unittest.TestCase):
    def setUp(self) -> None:
        """
        Perform set-up logic before executing any unit tests
        """
        self.s3: S3Client = boto3.client("s3", region_name="us-east-1")
        self.sts: STSClient = boto3.client("sts", region_name="us-east-1")
        self.synthetics = boto3.client("synthetics", region_name="us-east-1")
        self.events: EventsClient = boto3.client("events", region_name="us-east-1")

        self.prod_env = prod_env
        self.bucket_name = "saints-xctf-canaries"

        if self.prod_env:
            self.env = "prod"
        else:
            self.env = "dev"

    def test_canary_role_exists(self) -> None:
        """
        Test that the canary-role IAM Role exists.
        """
        self.assertTrue(IAM.iam_role_exists(role_name=f"canary-role"))

    def test_canary_policy_attached(self) -> None:
        """
        Test that the canary-policy is attached to the canary-role
        """
        self.assertTrue(
            IAM.iam_policy_attached_to_role(
                role_name=f"canary-role", policy_name=f"canary-policy"
            )
        )

    def test_saints_xctf_canaries_s3_bucket_exists(self) -> None:
        """
        Test if a saints-xctf-canaries S3 bucket exists
        """
        s3_bucket = self.s3.list_objects(Bucket=self.bucket_name)
        self.assertTrue(s3_bucket.get("Name") == self.bucket_name)

    def test_saints_xctf_canaries_s3_bucket_public_access(self) -> None:
        """
        Test whether the public access configuration for a saints-xctf-canaries S3 bucket is correct
        """
        public_access_block = self.s3.get_public_access_block(Bucket=self.bucket_name)
        config = public_access_block.get("PublicAccessBlockConfiguration")
        self.assertTrue(config.get("BlockPublicAcls"))
        self.assertTrue(config.get("IgnorePublicAcls"))
        self.assertTrue(config.get("BlockPublicPolicy"))
        self.assertTrue(config.get("RestrictPublicBuckets"))

    def test_saints_xctf_canaries_s3_bucket_has_policy(self) -> None:
        """
        Test if the saints-xctf-canaries S3 bucket has the expected policy attached to it.
        """
        account_id = self.sts.get_caller_identity().get("Account")

        bucket_policy_response = self.s3.get_bucket_policy(Bucket=self.bucket_name)
        bucket_policy: Dict[str, Any] = json.loads(bucket_policy_response.get("Policy"))

        self.assertEqual(bucket_policy.get("Version"), "2012-10-17")
        self.assertEqual(bucket_policy.get("Id"), "SaintsXCTFCanariesPolicy")

        statement: Dict[str, Any] = bucket_policy.get("Statement")[0]
        self.assertEqual(statement.get("Sid"), "Permissions")
        self.assertEqual(statement.get("Effect"), "Allow")
        self.assertEqual(
            statement.get("Principal").get("AWS"), f"arn:aws:iam::{account_id}:root"
        )
        self.assertEqual(statement.get("Action"), "s3:*")
        self.assertEqual(
            statement.get("Resource"), f"arn:aws:s3:::saints-xctf-canaries/*"
        )

    @unittest.skipIf(
        not prod_env, "Development SaintsXCTF Up canary function not under test."
    )
    def test_sxctf_up_canary_function_exists(self):
        """
        Test if a CloudWatch Synthetics Canary function exists called sxctf-up.
        """
        response = self.synthetics.get_canary(Name=f"sxctf-up-{self.env}")
        canary: Dict[str, Any] = response.get("Canary")

        self.assertEqual(canary.get("Name"), f"sxctf-up-{self.env}")
        self.assertEqual(canary.get("RuntimeVersion"), "syn-nodejs-puppeteer-3.1")
        self.assertEqual(canary.get("ArtifactS3Location"), "saints-xctf-canaries/")
        self.assertEqual(canary.get("SuccessRetentionPeriodInDays"), 2)
        self.assertEqual(canary.get("FailureRetentionPeriodInDays"), 14)
        self.assertEqual(canary.get("Code").get("Handler"), "up.handler")
        self.assertEqual(canary.get("Schedule").get("Expression"), "rate(1 hour)")

    @unittest.skipIf(
        not prod_env, "Development SaintsXCTF Up canary function not under test."
    )
    def test_sxctf_up_canary_event_rule_exists(self):
        """
        Test if a CloudWatch Event Rule exists for the sxctf-up Synthetics Canary function.
        """
        event_rules_response = self.events.list_rules()
        event_rules: List[Dict[str, str]] = event_rules_response.get("Rules")
        matching_event_rules = [
            rule
            for rule in event_rules
            if rule.get("Name") == "saints-xctf-up-canary-rule"
        ]

        self.assertEqual(1, len(matching_event_rules))

        matching_event: Dict[str, str] = matching_event_rules[0]
        self.assertEqual("ENABLED", matching_event.get("State"))

        event_pattern: Dict[str, Any] = json.loads(matching_event.get("EventPattern"))
        canary_names: List[str] = event_pattern.get("detail").get("canary-name")
        self.assertEqual(1, len(canary_names))
        self.assertEqual(f"sxctf-up-{self.env}", canary_names[0])

        test_statuses: List[str] = event_pattern.get("detail").get("test-run-status")
        self.assertEqual(1, len(test_statuses))
        self.assertEqual("FAILED", test_statuses[0])

        sources: List[str] = event_pattern.get("source")
        self.assertEqual(1, len(sources))
        self.assertEqual("aws.synthetics", sources[0])

    def test_sxctf_up_canary_event_target_exists(self):
        """
        Test if a CloudWatch Event Rule exists for the sxctf-up Synthetics Canary function.
        """
        account_id = self.sts.get_caller_identity().get("Account")

        event_targets_response = self.events.list_targets_by_rule(
            Rule="saints-xctf-up-canary-rule"
        )
        event_targets = event_targets_response.get("Targets")
        self.assertEqual(1, len(event_targets))

        event_target = event_targets[0]
        self.assertEqual("SaintsXCTFUpCanaryTarget", event_target.get("Id"))
        self.assertEqual(
            f"arn:aws:sns:us-east-1:{account_id}:alert-email-topic",
            event_target.get("Arn"),
        )

    @unittest.skipIf(
        not prod_env, "Development SaintsXCTF Sign In canary function not under test."
    )
    def test_sxctf_sign_in_canary_function_exists(self):
        """
        Test if a CloudWatch Synthetics Canary function exists called sxctf-sign-in.
        """
        response = self.synthetics.get_canary(Name=f"sxctf-sign-in-{self.env}")
        canary: Dict[str, Any] = response.get("Canary")

        self.assertEqual(canary.get("Name"), f"sxctf-sign-in-{self.env}")
        self.assertEqual(canary.get("RuntimeVersion"), "syn-nodejs-puppeteer-3.1")
        self.assertEqual(canary.get("ArtifactS3Location"), "saints-xctf-canaries/")
        self.assertEqual(canary.get("SuccessRetentionPeriodInDays"), 2)
        self.assertEqual(canary.get("FailureRetentionPeriodInDays"), 14)
        self.assertEqual(canary.get("Code").get("Handler"), "signIn.handler")
        self.assertEqual(canary.get("Schedule").get("Expression"), "rate(1 hour)")

    @unittest.skipIf(
        not prod_env, "Development SaintsXCTF Sign In canary function not under test."
    )
    def test_sxctf_sign_in_canary_event_rule_exists(self):
        """
        Test if a CloudWatch Event Rule exists for the sxctf-sign-in Synthetics Canary function.
        """
        event_rules_response = self.events.list_rules()
        event_rules: List[Dict[str, str]] = event_rules_response.get("Rules")
        matching_event_rules = [
            rule
            for rule in event_rules
            if rule.get("Name") == "saints-xctf-sign-in-canary-rule"
        ]

        self.assertEqual(1, len(matching_event_rules))

        matching_event: Dict[str, str] = matching_event_rules[0]
        self.assertEqual("ENABLED", matching_event.get("State"))

        event_pattern: Dict[str, Any] = json.loads(matching_event.get("EventPattern"))
        canary_names: List[str] = event_pattern.get("detail").get("canary-name")
        self.assertEqual(1, len(canary_names))
        self.assertEqual(f"sxctf-sign-in-{self.env}", canary_names[0])

        test_statuses: List[str] = event_pattern.get("detail").get("test-run-status")
        self.assertEqual(1, len(test_statuses))
        self.assertEqual("FAILED", test_statuses[0])

        sources: List[str] = event_pattern.get("source")
        self.assertEqual(1, len(sources))
        self.assertEqual("aws.synthetics", sources[0])

    def test_sxctf_sign_in_canary_event_target_exists(self):
        """
        Test if a CloudWatch Event Rule Target exists for the sxctf-sign-in Synthetics Canary function.
        """
        account_id = self.sts.get_caller_identity().get("Account")

        event_targets_response = self.events.list_targets_by_rule(
            Rule="saints-xctf-sign-in-canary-rule"
        )
        event_targets = event_targets_response.get("Targets")
        self.assertEqual(1, len(event_targets))

        event_target = event_targets[0]
        self.assertEqual("SaintsXCTFSignInCanaryTarget", event_target.get("Id"))
        self.assertEqual(
            f"arn:aws:sns:us-east-1:{account_id}:alert-email-topic",
            event_target.get("Arn"),
        )

    @unittest.skipIf(
        not prod_env,
        "Development SaintsXCTF Forgot Password canary function not under test.",
    )
    def test_sxctf_forgot_password_canary_function_exists(self):
        """
        Test if a CloudWatch Synthetics Canary function exists called sxctf-forgot-pw.
        """
        response = self.synthetics.get_canary(Name=f"sxctf-forgot-pw-{self.env}")
        canary: Dict[str, Any] = response.get("Canary")

        self.assertEqual(canary.get("Name"), f"sxctf-forgot-pw-{self.env}")
        self.assertEqual(canary.get("RuntimeVersion"), "syn-python-selenium-1.0")
        self.assertEqual(canary.get("ArtifactS3Location"), "saints-xctf-canaries/")
        self.assertEqual(canary.get("SuccessRetentionPeriodInDays"), 2)
        self.assertEqual(canary.get("FailureRetentionPeriodInDays"), 14)
        self.assertEqual(canary.get("Code").get("Handler"), "forgot_password.handler")
        self.assertEqual(canary.get("Schedule").get("Expression"), "rate(1 hour)")

    @unittest.skipIf(
        not prod_env,
        "Development SaintsXCTF Forgot Password canary function not under test.",
    )
    def test_sxctf_forgot_password_canary_event_rule_exists(self):
        """
        Test if a CloudWatch Event Rule exists for the sxctf-forgot-pw Synthetics Canary function.
        """
        event_rules_response = self.events.list_rules()
        event_rules: List[Dict[str, str]] = event_rules_response.get("Rules")
        matching_event_rules = [
            rule
            for rule in event_rules
            if rule.get("Name") == "saints-xctf-forgot-password-canary-rule"
        ]

        self.assertEqual(1, len(matching_event_rules))

        matching_event: Dict[str, str] = matching_event_rules[0]
        self.assertEqual("ENABLED", matching_event.get("State"))

        event_pattern: Dict[str, Any] = json.loads(matching_event.get("EventPattern"))
        canary_names: List[str] = event_pattern.get("detail").get("canary-name")
        self.assertEqual(1, len(canary_names))
        self.assertEqual(f"sxctf-forgot-pw-{self.env}", canary_names[0])

        test_statuses: List[str] = event_pattern.get("detail").get("test-run-status")
        self.assertEqual(1, len(test_statuses))
        self.assertEqual("FAILED", test_statuses[0])

        sources: List[str] = event_pattern.get("source")
        self.assertEqual(1, len(sources))
        self.assertEqual("aws.synthetics", sources[0])

    def test_sxctf_forgot_password_canary_event_target_exists(self):
        """
        Test if a CloudWatch Event Rule Target exists for the sxctf-forgot-pw Synthetics Canary function.
        """
        account_id = self.sts.get_caller_identity().get("Account")

        event_targets_response = self.events.list_targets_by_rule(
            Rule="saints-xctf-forgot-password-canary-rule"
        )
        event_targets = event_targets_response.get("Targets")
        self.assertEqual(1, len(event_targets))

        event_target = event_targets[0]
        self.assertEqual("SaintsXCTFForgotPasswordCanaryTarget", event_target.get("Id"))
        self.assertEqual(
            f"arn:aws:sns:us-east-1:{account_id}:alert-email-topic",
            event_target.get("Arn"),
        )
