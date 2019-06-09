/**
 * Variables for the saintsxctf RDS database snapshot lambda function
 * Author: Andrew Jarombek
 * Date: 6/7/2019
 */

variable "prod" {
  description = "If the environment that rds instance lives in is production"
  default = true
}

variable "secrets" {
  description = "Secrets for the RDS instance to place in AWS Secret Manager.  Never use the default value beyond POC"
  default = {
    username = "andy"
    password = "password"
  }

  type = map
}