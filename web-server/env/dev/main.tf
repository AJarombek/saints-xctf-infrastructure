/**
 * Infrastructure for the saintsxctf launch configuration in the DEV environment
 * Author: Andrew Jarombek
 * Date: 12/10/2018
 */

locals {
  max_size_on = 1
  min_size_on = 1
  desired_capacity_on = 1

  max_size_off = 0
  min_size_off = 0
  desired_capacity_off = 0
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/web-server/env/dev"
    region = "us-east-1"
  }
}

module "launch-config" {
  source = "../../modules/launch-config"
  prod = false

  autoscaling_schedules = [
    {
      name = "saints-xctf-server-online-weekday-morning"
      max_size = "${local.max_size_on}"
      min_size = "${local.min_size_on}"
      desired_capacity = "${local.desired_capacity_on}"
      recurrence = "30 11 * * 1-5"
    },
    {
      name = "saints-xctf-server-offline-weekday-morning"
      max_size = "${local.max_size_off}"
      min_size = "${local.min_size_off}"
      desired_capacity = "${local.desired_capacity_off}"
      recurrence = "30 13 * * 1-5"
    },
    {
      name = "saints-xctf-server-online-weekday-afternoon"
      max_size = "${local.max_size_on}"
      min_size = "${local.min_size_on}"
      desired_capacity = "${local.desired_capacity_on}"
      recurrence = "30 22 * * 1-5"
    },
    {
      name = "saints-xctf-server-offline-weekday-night"
      max_size = "${local.max_size_off}"
      min_size = "${local.min_size_off}"
      desired_capacity = "${local.desired_capacity_off}"
      recurrence = "30 3 * * 2-6"
    },
    {
      name = "saints-xctf-server-online-weekend"
      max_size = "${local.max_size_on}"
      min_size = "${local.min_size_on}"
      desired_capacity = "${local.desired_capacity_on}"
      recurrence = "30 11 * * 0,6"
    },
    {
      name = "saints-xctf-server-offline-weekend"
      max_size = "${local.max_size_off}"
      min_size = "${local.min_size_off}"
      desired_capacity = "${local.desired_capacity_off}"
      recurrence = "30 3 * * 0,1"
    }
  ]
}