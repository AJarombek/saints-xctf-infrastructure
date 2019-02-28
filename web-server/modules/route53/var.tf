/**
 * Variables for the saintsxctf website route53 DNS configuration
 * Author: Andrew Jarombek
 * Date: 2/28/2019
 */

variable "prod" {
  description = "If the environment of the launch configuration is production"
  default = false
}

variable "lb_zone_id" {
  description = "Zone ID of the application load balancer"
  default = ""
}

variable "lb_dns_name" {
  description = "DNS name of the application load balancer"
  default = ""
}