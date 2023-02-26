/**
 * Variables for an S3 bucket used for backing up the MySQL saintsxctf database
 * Author: Andrew Jarombek
 * Date: 12/5/2018
 */

variable "prod" {
  description = "If the environment that the S3 bucket lives in is production"
  default     = false
}