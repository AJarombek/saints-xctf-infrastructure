/**
 * Variables for the SaintsXCTF credentials stored in AWS Secrets Manager
 * Author: Andrew Jarombek
 * Date: 6/14/2019
 */

variable "prod" {
  description = "If the environment of the secrets is production."
  default     = true
}

variable "rds_secrets" {
  description = "Secrets for the RDS instance to place in AWS Secret Manager.  Never use the default value beyond POC"
  default = {
    username = "andy"
    password = "password"
  }

  type = map(any)
}