/**
 * Variables for the SaintsXCTF credentials stored in AWS Secrets Manager in the production environment.
 * Author: Andrew Jarombek
 * Date: 8/31/2019
 */

variable "rds_secrets" {
  description = "Secrets for the RDS production instance to place in AWS Secret Manager.  Never use the default values."
  default = {
    username = "andy"
    password = "password"
  }

  type = map(any)
}