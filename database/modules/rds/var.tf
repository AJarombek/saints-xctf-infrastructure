/**
 * Variables for the MySQL saintsxctf database
 * Author: Andrew Jarombek
 * Date: 12/4/2018
 */

variable "prod" {
  description = "If the environment that rds instance lives in is production"
  default = false
}

variable "username" {
  description = "Master username for the database"
  default = "andy"
}

variable "password" {
  description = "Master password for the database"
  default = "andy"
}