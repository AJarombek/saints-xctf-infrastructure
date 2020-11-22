/**
 * Input variables for the AWS Lambda function.
 * Author: Andrew Jarombek
 * Date: 11/21/2020
 */

variable "prod" {
  description = "If the environment of the AWS Lambda function is production"
  default = true
}