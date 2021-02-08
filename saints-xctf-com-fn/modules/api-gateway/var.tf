/**
 * Input variables for the AWS Lambda function.
 * Author: Andrew Jarombek
 * Date: 5/24/2020
 */

variable "prod" {
  description = "If the environment of the API Gateway service is production"
  default = true
}

variable "email-forgot-password-lambda-name" {
  description = "The name of the forgot password email Lambda function to use with API Gateway"
}

variable "email-forgot-password-lambda-invoke-arn" {
  description = "The Amazon Resource Name of the forgot password email Lambda function to use with API Gateway"
}

variable "email-activation-code-lambda-name" {
  description = "The name of the activation code email Lambda function to use with API Gateway"
}

variable "email-activation-code-lambda-invoke-arn" {
  description = "The Amazon Resource Name of the activation code email Lambda function to use with API Gateway"
}

variable "email-welcome-lambda-name" {
  description = "The name of the welcome email Lambda function to use with API Gateway"
}

variable "email-welcome-lambda-invoke-arn" {
  description = "The Amazon Resource Name of the welcome email Lambda function to use with API Gateway"
}

variable "uasset-user-lambda-name" {
  description = "The name of the user asset 'user' Lambda function to use with API Gateway"
}

variable "uasset-user-lambda-invoke-arn" {
  description = "The Amazon Resource Name of the user asset 'user' Lambda function to use with API Gateway"
}

variable "uasset-group-lambda-name" {
  description = "The name of the user asset 'group' Lambda function to use with API Gateway"
}

variable "uasset-group-lambda-invoke-arn" {
  description = "The Amazon Resource Name of the user asset 'group' Lambda function to use with API Gateway"
}