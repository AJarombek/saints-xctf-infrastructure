/**
 * Input variables for the AWS Lambda function.
 * Author: Andrew Jarombek
 * Date: 5/24/2020
 */

variable "prod" {
  description = "If the environment of the API Gateway service is production"
  default = true
}

variable "email-lambda-name" {
  description = "The name of the email Lambda function to use with API Gateway"
}

variable "email-lambda-invoke-arn" {
  description = "The Amazon Resource Name of the email Lambda function to use with API Gateway"
}

variable "uasset-user-lambda-name" {
  description = "The name of the user asset 'user' Lambda function to use with API Gateway"
}

variable "uasset-user-lambda-invoke-arn" {
  description = "The Amazon Resource Name of the user asset 'user' Lambda function to use with API Gateway"
}