/**
 * Variables for the saintsxctf website route53 DNS configuration
 * Author: Andrew Jarombek
 * Date: 2/28/2019
 */

variable "prod" {
  description = "If the environment of the launch configuration is production"
  default = false
}