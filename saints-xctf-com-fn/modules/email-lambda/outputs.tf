/**
 * Output variables for the AWS Lambda function.
 * Author: Andrew Jarombek
 * Date: 5/24/2020
 */

output "forgot-password-function-name" {
  value = local.lambda_functions.forgot_password.function_name
}

output "forgot-password-function-invoke-arn" {
  value = [
    for function in aws_lambda_function.email : function.function_name
    if function.function_name == local.lambda_functions.forgot_password.function_name
  ][0]
}

output "activation-code-function-name" {
  value = local.lambda_functions.activation_code.function_name
}

output "activation-code-invoke-arn" {
  value = [
    for function in aws_lambda_function.email : function.function_name
    if function.function_name == local.lambda_functions.activation_code.function_name
  ][0]
}