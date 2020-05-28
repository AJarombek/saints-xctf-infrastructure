/**
 * Output variables for the authentication AWS Lambda function.
 * Author: Andrew Jarombek
 * Date: 5/25/2020
 */

output "function-name" {
  value = aws_lambda_function.auth.function_name
}

output "function-invoke-arn" {
  value = aws_lambda_function.auth.invoke_arn
}