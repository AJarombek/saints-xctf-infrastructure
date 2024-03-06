/**
 * Variables for the MySQL saintsxctf database
 * Author: Andrew Jarombek
 * Date: 12/4/2018
 */

variable "prod" {
  description = "If the environment that rds instance lives in is production"
  type        = bool
  default     = false
}

variable "username" {
  description = "Master username for the database"
  type        = string
  default     = "andy"
  sensitive   = true
}

variable "password" {
  description = "Master password for the database"
  type        = string
  default     = "abcd"
  sensitive   = true
}

variable "terraform_tag" {
  description = "Terraform tag, representing the terraform module that built the infrastructure"
  type        = string
}