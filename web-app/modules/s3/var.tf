/**
 * Variables for the global S3 bucket holding SaintsXCTF credentials
 * Author: Andrew Jarombek
 * Date: 2/16/2019
 */

variable "prod" {
  description = "If the environment of the launch configuration is production"
  default = false
}

variable "contents" {
  description = "Objects to put into the S3 bucket"
  type = "list"
  default = []
}