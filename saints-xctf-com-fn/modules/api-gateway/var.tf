/**
 * Input variables for the AWS Lambda function.
 * Author: Andrew Jarombek
 * Date: 5/24/2020
 */

variable "prod" {
  description = "If the environment of the API Gateway service is production"
  type = bool
  default = true
}

/* API Gateway Config Variables */

variable "enable-xray-tracing" {
  description = "Whether or not AWS X-Ray tracing should be enabled for the API Gateway stage"
  type = bool
  default = false
}

/* Lambda Function Variables */

variable "email-forgot-password-lambda-name" {
  description = "The name of the forgot password email Lambda function to use with API Gateway"
  type = string

  validation {
    condition = length(var.email-forgot-password-lambda-name) >= 1
    error_message = "The forgot password email lambda name must be of length greater than 1."
  }
}

variable "email-forgot-password-lambda-invoke-arn" {
  description = "The Amazon Resource Name of the forgot password email Lambda function to use with API Gateway"
  type = string

  validation {
    condition = substr(var.email-forgot-password-lambda-invoke-arn, 0, 19) == "arn:aws:apigateway:"
    error_message = "The email forgot password lambda arn is not formatted properly."
  }
}

variable "email-activation-code-lambda-name" {
  description = "The name of the activation code email Lambda function to use with API Gateway"
  type = string

  validation {
    condition = length(var.email-activation-code-lambda-name) >= 1
    error_message = "The activation code email lambda name must be of length greater than 1."
  }
}

variable "email-activation-code-lambda-invoke-arn" {
  description = "The Amazon Resource Name of the activation code email Lambda function to use with API Gateway"
  type = string

  validation {
    condition = substr(var.email-activation-code-lambda-invoke-arn, 0, 19) == "arn:aws:apigateway:"
    error_message = "The email activation code lambda arn is not formatted properly."
  }
}

variable "email-report-lambda-name" {
  description = "The name of the report email Lambda function to use with API Gateway"
  type = string

  validation {
    condition = length(var.email-report-lambda-name) >= 1
    error_message = "The report email lambda name must be of length greater than 1."
  }
}

variable "email-report-lambda-invoke-arn" {
  description = "The Amazon Resource Name of the report email Lambda function to use with API Gateway"
  type = string

  validation {
    condition = substr(var.email-report-lambda-invoke-arn, 0, 19) == "arn:aws:apigateway:"
    error_message = "The email report lambda arn is not formatted properly."
  }
}

variable "email-welcome-lambda-name" {
  description = "The name of the welcome email Lambda function to use with API Gateway"
  type = string

  validation {
    condition = length(var.email-welcome-lambda-name) >= 1
    error_message = "The welcome email lambda name must be of length greater than 1."
  }
}

variable "email-welcome-lambda-invoke-arn" {
  description = "The Amazon Resource Name of the welcome email Lambda function to use with API Gateway"
  type = string

  validation {
    condition = substr(var.email-welcome-lambda-invoke-arn, 0, 19) == "arn:aws:apigateway:"
    error_message = "The email welcome lambda arn is not formatted properly."
  }
}

variable "uasset-user-lambda-name" {
  description = "The name of the user asset 'user' Lambda function to use with API Gateway"
  type = string

  validation {
    condition = length(var.uasset-user-lambda-name) >= 1
    error_message = "The uasset user lambda name must be of length greater than 1."
  }
}

variable "uasset-user-lambda-invoke-arn" {
  description = "The Amazon Resource Name of the user asset 'user' Lambda function to use with API Gateway"
  type = string

  validation {
    condition = substr(var.uasset-user-lambda-invoke-arn, 0, 19) == "arn:aws:apigateway:"
    error_message = "The uasset user lambda arn is not formatted properly."
  }
}

variable "uasset-group-lambda-name" {
  description = "The name of the user asset 'group' Lambda function to use with API Gateway"
  type = string

  validation {
    condition = length(var.uasset-group-lambda-name) >= 1
    error_message = "The uasset group lambda name must be of length greater than 1."
  }
}

variable "uasset-group-lambda-invoke-arn" {
  description = "The Amazon Resource Name of the user asset 'group' Lambda function to use with API Gateway"
  type = string

  validation {
    condition = substr(var.uasset-group-lambda-invoke-arn, 0, 19) == "arn:aws:apigateway:"
    error_message = "The uasset group lambda arn is not formatted properly."
  }
}

variable "uasset-user-signed-url-lambda-name" {
  description = "The name of the user asset signed url 'user' Lambda function to use with API Gateway"
  type = string

  validation {
    condition = length(var.uasset-user-signed-url-lambda-name) >= 1
    error_message = "The uasset signed url user lambda name must be of length greater than 1."
  }
}

variable "uasset-user-signed-url-lambda-invoke-arn" {
  description = "The Amazon Resource Name of the user asset signed url 'user' Lambda function to use with API Gateway"
  type = string

  validation {
    condition = substr(var.uasset-user-signed-url-lambda-invoke-arn, 0, 19) == "arn:aws:apigateway:"
    error_message = "The uasset signed url user lambda arn is not formatted properly."
  }
}

variable "uasset-group-signed-url-lambda-name" {
  description = "The name of the user asset signed url 'group' Lambda function to use with API Gateway"
  type = string

  validation {
    condition = length(var.uasset-group-signed-url-lambda-name) >= 1
    error_message = "The uasset signed url group lambda name must be of length greater than 1."
  }
}

variable "uasset-group-signed-url-lambda-invoke-arn" {
  description = "The Amazon Resource Name of the user asset signed url 'group' Lambda function to use with API Gateway"
  type = string

  validation {
    condition = substr(var.uasset-group-signed-url-lambda-invoke-arn, 0, 19) == "arn:aws:apigateway:"
    error_message = "The uasset signed url group lambda arn is not formatted properly."
  }
}