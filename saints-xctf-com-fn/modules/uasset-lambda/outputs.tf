/**
 * Output variables for the AWS Lambda functions.
 * Author: Andrew Jarombek
 * Date: 11/21/2020
 */

output "uasset-user-function-name" {
  value = local.lambda_functions.uasset_user.function_name
}

output "uasset-user-function-invoke-arn" {
  value = [
    for function in aws_lambda_function.uasset : function.invoke_arn
    if function.function_name == local.lambda_functions.uasset_user.function_name
  ][0]
}

output "uasset-group-function-name" {
  value = local.lambda_functions.uasset_group.function_name
}

output "uasset-group-function-invoke-arn" {
  value = [
    for function in aws_lambda_function.uasset : function.invoke_arn
    if function.function_name == local.lambda_functions.uasset_group.function_name
  ][0]
}