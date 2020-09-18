/**
 * Infrastructure for an S3 bucket used for SaintsXCTF database deployments.
 * Author: Andrew Jarombek
 * Date: 9/17/2020
 */

locals {
  env = var.prod ? "prod" : "dev"
}