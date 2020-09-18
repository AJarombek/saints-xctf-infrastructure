/**
 * Variables for the SaintsXCTF RDS database deployment S3 bucket
 * Author: Andrew Jarombek
 * Date: 9/17/2020
 */

variable "prod" {
  description = "If the environment of the database deployment is production"
  default = false
}