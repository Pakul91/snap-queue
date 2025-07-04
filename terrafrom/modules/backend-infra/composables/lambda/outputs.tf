#OUTPUTS

# Outputs for the Lambda function - allows other resources to reference the function details outside this module
output "arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.function.arn
}

output "invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.function.invoke_arn
}

output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.function.function_name
}

output "function_execution_role" {
  description = "Execution role for the Lambda function"
  value       = aws_iam_role.lambda_execution_role
}