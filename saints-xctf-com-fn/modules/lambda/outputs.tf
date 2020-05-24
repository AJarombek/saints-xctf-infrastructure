/**
 * Output variables for the AWS Lambda function.
 * Author: Andrew Jarombek
 * Date: 5/24/2020
 */

output "function-name" {
  value = aws_lambda_function.forgot-password-email.function_name
}

output "function-invoke-arn" {
  value = aws_lambda_function.forgot-password-email.invoke_arn
}