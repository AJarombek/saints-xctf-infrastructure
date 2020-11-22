/**
 * Output variables for the AWS Lambda functions.
 * Author: Andrew Jarombek
 * Date: 11/21/2020
 */

output "user-function-name" {
  value = aws_lambda_function.forgot-password-email.function_name
}

output "user-function-invoke-arn" {
  value = aws_lambda_function.forgot-password-email.invoke_arn
}