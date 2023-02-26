/**
 * Input variables for the authentication API Gateway service.
 * Author: Andrew Jarombek
 * Date: 5/29/2020
 */

variable "prod" {
  description = "If the environment of the API Gateway service is production"
  default     = true
}

variable "authenticate-lambda-name" {
  description = "The name of the authentication Lambda function to use with API Gateway"
  type        = string

  validation {
    condition     = length(var.authenticate-lambda-name) >= 1
    error_message = "The authenticate lambda name must be of length greater than 1."
  }
}

variable "authenticate-lambda-invoke-arn" {
  description = "The Amazon Resource Name of the authentication Lambda function to use with API Gateway"
  type        = string

  validation {
    condition     = substr(var.authenticate-lambda-invoke-arn, 0, 19) == "arn:aws:apigateway:"
    error_message = "The authenticate lambda arn is not formatted properly."
  }
}

variable "token-lambda-name" {
  description = "The name of the token Lambda function to use with API Gateway"
  type        = string

  validation {
    condition     = length(var.token-lambda-name) >= 1
    error_message = "The token lambda name must be of length greater than 1."
  }
}

variable "token-lambda-invoke-arn" {
  description = "The Amazon Resource Name of the token Lambda function to use with API Gateway"
  type        = string

  validation {
    condition     = substr(var.token-lambda-invoke-arn, 0, 19) == "arn:aws:apigateway:"
    error_message = "The token lambda arn is not formatted properly."
  }
}