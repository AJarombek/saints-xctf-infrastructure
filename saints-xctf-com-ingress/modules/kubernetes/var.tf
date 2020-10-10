/**
 * Variables for the saintsxctf.com Kubernetes Ingress.
 * Author: Andrew Jarombek
 * Date: 10/9/2020
 */

variable "prod" {
  description = "If the environment for the saintsxctf.com Kubernetes Ingress is production"
  default = false
}