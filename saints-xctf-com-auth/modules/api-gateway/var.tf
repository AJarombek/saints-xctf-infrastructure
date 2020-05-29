/**
 * Input variables for the authentication API Gateway service.
 * Author: Andrew Jarombek
 * Date: 5/29/2020
 */

variable "prod" {
  description = "If the environment of the API Gateway service is production"
  default = true
}

variable "authenticate-lambda-name" {
  description = "The name of the authentication Lambda function to use with API Gateway"
}

variable "authenticate-lambda-invoke-arn" {
  description = "The Amazon Resource Name of the authentication Lambda function to use with API Gateway"
}

variable "token-lambda-name" {
  description = "The name of the token Lambda function to use with API Gateway"
}

variable "token-lambda-invoke-arn" {
  description = "The Amazon Resource Name of the token Lambda function to use with API Gateway"
}