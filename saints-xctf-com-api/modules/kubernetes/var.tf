/**
 * Variables for the Kubernetes infrastructure
 * Author: Andrew Jarombek
 * Date: 7/13/2020
 */

variable "prod" {
  description = "If the environment for the Kubernetes infrastructure is production"
  default     = false
}