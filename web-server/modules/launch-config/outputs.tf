/**
 * Output variables to be used outside the launch configuration module
 * Author: Andrew Jarombek
 * Date: 2/28/2019
 */

output "load-balancer-zone-id" {
  value = "${aws_lb.saints-xctf-server-application-lb.zone_id}"
}

output "load-balancer-dns-name" {
  value = "${aws_lb.saints-xctf-server-application-lb.dns_name}"
}