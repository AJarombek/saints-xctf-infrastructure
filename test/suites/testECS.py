"""
Unit tests for the ECS cluster, services, and target groups defined in ecs/main.tf
Author: Andrew Jarombek
Date: 8/4/2025
"""

import unittest
import boto3


class TestECS(unittest.TestCase):
    def setUp(self) -> None:
        self.ecs = boto3.client("ecs", region_name="us-east-1")
        self.elbv2 = boto3.client("elbv2", region_name="us-east-1")
        self.cluster_name = "saintsxctf"
        self.ui_service = "saintsxctf-ui"
        self.api_service = "saintsxctf-api"
        self.ui_tg = "saintsxctf-ui-tg"
        self.api_tg = "saintsxctf-api-tg"

    def test_ecs_cluster_exists(self):
        clusters = self.ecs.list_clusters()["clusterArns"]
        found = any(self.cluster_name in arn for arn in clusters)
        self.assertTrue(found, f"ECS cluster '{self.cluster_name}' does not exist.")

    def test_ecs_services_exist(self):
        services = self.ecs.list_services(cluster=self.cluster_name)["serviceArns"]
        ui_found = any(self.ui_service in arn for arn in services)
        api_found = any(self.api_service in arn for arn in services)
        self.assertTrue(ui_found, f"ECS service '{self.ui_service}' does not exist.")
        self.assertTrue(api_found, f"ECS service '{self.api_service}' does not exist.")

    def test_target_groups_exist(self):
        tgs = self.elbv2.describe_target_groups()["TargetGroups"]
        tg_names = [tg["TargetGroupName"] for tg in tgs]
        self.assertIn(
            self.ui_tg, tg_names, f"Target group '{self.ui_tg}' does not exist."
        )
        self.assertIn(
            self.api_tg, tg_names, f"Target group '{self.api_tg}' does not exist."
        )

    def test_ecs_cluster_active(self):
        clusters = self.ecs.describe_clusters(clusters=[self.cluster_name])["clusters"]
        self.assertTrue(clusters, f"ECS cluster '{self.cluster_name}' not found.")
        self.assertEqual(
            clusters[0]["status"],
            "ACTIVE",
            f"ECS cluster '{self.cluster_name}' is not ACTIVE.",
        )

    def test_ecs_service_running_tasks(self):
        for service in [self.ui_service, self.api_service]:
            response = self.ecs.describe_services(
                cluster=self.cluster_name, services=[service]
            )
            services = response["services"]
            self.assertTrue(services, f"ECS service '{service}' not found.")
            running_count = services[0]["runningCount"]
            self.assertGreater(
                running_count, 0, f"ECS service '{service}' has no running tasks."
            )

    def test_target_groups_have_healthy_targets(self):
        for tg_name in [self.ui_tg, self.api_tg]:
            tgs = self.elbv2.describe_target_groups(Names=[tg_name])["TargetGroups"]
            self.assertTrue(tgs, f"Target group '{tg_name}' not found.")
            tg_arn = tgs[0]["TargetGroupArn"]
            health = self.elbv2.describe_target_health(TargetGroupArn=tg_arn)[
                "TargetHealthDescriptions"
            ]
            healthy = any(t["TargetHealth"]["State"] == "healthy" for t in health)
            self.assertTrue(healthy, f"No healthy targets in target group '{tg_name}'.")

    def test_ecs_service_desired_count(self):
        for service in [self.ui_service, self.api_service]:
            response = self.ecs.describe_services(
                cluster=self.cluster_name, services=[service]
            )
            services = response["services"]
            self.assertTrue(services, f"ECS service '{service}' not found.")
            desired_count = services[0]["desiredCount"]
            self.assertGreaterEqual(
                desired_count,
                1,
                f"ECS service '{service}' desired count is less than 1.",
            )
