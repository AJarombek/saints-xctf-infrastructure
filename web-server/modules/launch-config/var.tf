/**
 * Variables for the saintsxctf website launch configuration of EC2 instances
 * Author: Andrew Jarombek
 * Date: 12/10/2018
 */

variable "prod" {
  description = "If the environment of the launch configuration is production"
  default = false
}