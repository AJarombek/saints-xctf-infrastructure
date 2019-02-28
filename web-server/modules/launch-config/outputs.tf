/**
 * Output variables to be used outside the launch configuration module
 * Author: Andrew Jarombek
 * Date: 2/28/2019
 */

output "load-balancer" {
  value = "${aws_lb.saints-xctf-server-application-lb.id}"
}

output "instances" {
  value = "${aws_autoscaling_group.saints-xctf-asg.}"
}