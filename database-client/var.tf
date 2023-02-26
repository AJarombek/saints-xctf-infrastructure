/**
 * Variables for the database client Kubernetes & AWS infrastructure.
 * Author: Andrew Jarombek
 * Date: 3/16/2021
 */

variable "db_client_access_cidr" {
  description = "CIDR block that has access to the database client"
  default     = "0.0.0.0/0"
  type        = string

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}(/([0-9]|[1-2][0-9]|3[0-2]))$", var.db_client_access_cidr))
    error_message = "An invalid CIDR block was provided for SaintsXCTF database client access."
  }
}