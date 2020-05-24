/**
 * Input variables for the AWS Lambda function.
 * Author: Andrew Jarombek
 * Date: 5/24/2020
 */

variable "prod" {
  description = "If the environment of the API Gateway service is production"
  default = true
}

variable "lambda-function-name" {
  description = "The name of the AWS Lambda function to use with API Gateway"
}

variable "lambda-function-invoke-arn" {
  description = "The name of the AWS Lambda function to use with API Gateway"
}