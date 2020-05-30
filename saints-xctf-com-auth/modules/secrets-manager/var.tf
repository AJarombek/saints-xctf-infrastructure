/**
 * Input variables for the AWS Lambda function.
 * Author: Andrew Jarombek
 * Date: 5/28/2020
 */

variable "prod" {
  description = "If the environment of the secrets is production."
  default = true
}

variable "rotation-lambda-invoke-arn" {
  description = "The Amazon Resource Name of the auth secret rotation Lambda function."
}