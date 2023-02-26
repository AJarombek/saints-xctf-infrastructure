/**
 * Input variables for the authentication AWS Lambda function.
 * Author: Andrew Jarombek
 * Date: 5/25/2020
 */

variable "prod" {
  description = "If the environment of the AWS Lambda function is production"
  default     = true
}