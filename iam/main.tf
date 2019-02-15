/**
 * IAM policies for the saintsxctf infrastructure
 * Author: Andrew Jarombek
 * Date: 2/15/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/iam"
    region = "us-east-1"
  }
}

# ---------
# IAM Roles
# ---------

resource "aws_iam_role" "rds-access-role" {
  name = "rds-access-role"
  path = "/saintsxctf/"
  assume_role_policy = "${file("policies/assume-role-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "rds-access-role-policy" {
  policy_arn = "${aws_iam_policy.rds-access-policy.arn}"
  role = "${aws_iam_role.rds-access-role.name}"
}

# ------------
# IAM Policies
# ------------

resource "aws_iam_policy" "rds-access-policy" {
  name = "rds-access-policy"
  path = "/saintsxctf/"
  policy = "${file("policies/rds-access-policy.json")}"
}