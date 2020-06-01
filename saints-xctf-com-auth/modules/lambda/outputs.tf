/**
 * Output variables for the auth AWS Lambda functions.
 * Author: Andrew Jarombek
 * Date: 5/25/2020
 */

output "authenticate-function-name" {
  value = aws_lambda_function.authenticate.function_name
}

output "authenticate-function-invoke-arn" {
  value = aws_lambda_function.authenticate.invoke_arn
}

output "token-function-name" {
  value = aws_lambda_function.token.function_name
}

output "token-function-invoke-arn" {
  value = aws_lambda_function.token.invoke_arn
}

output "rotate-function-arn" {
  value = aws_lambda_function.rotate.arn
}

output "rotate-secrets-manager-permission-id" {
  value = aws_lambda_permission.rotate-secrets-manager-permission.id
}

output "rotate-log-group-id" {
  value = aws_cloudwatch_log_group.rotate-log-group.id
}