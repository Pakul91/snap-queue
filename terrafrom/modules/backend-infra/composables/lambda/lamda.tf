

# CloudWatch Log Group with retention - Automatically created for Lambda function logs
# Sets a 14-day retention period to manage storage costs while keeping logs available
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14

  tags = merge(var.tags, {
    Environment = var.env
    Function    = var.lambda_function_name
    Namespace   = var.namespace
  })
}


# Package the Lambda function code - Zips up the source code files for deployment
# This creates the deployment package that will be uploaded to AWS Lambda
data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "${path.root}/lambda-functions/${var.lambda_folder_name}"
  output_path = "${path.root}/lambda-archive/${var.lambda_folder_name}.zip"
}


# Lambda function - Defines the serverless function that will execute our Node.js code
# Configures runtime, permissions, environment variables, and source code location
resource "aws_lambda_function" "function" {
  filename         = data.archive_file.function_zip.output_path
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = var.lambda_handler
  source_code_hash = data.archive_file.function_zip.output_base64sha256
  runtime          = var.lambda_runtime
  timeout          = var.timeout
  memory_size      = var.memory_size

  environment {
    variables = var.env_variables
  }

  tags = var.tags

  depends_on = [aws_iam_role_policy_attachment.lambda_logs, aws_cloudwatch_log_group.lambda_log_group]
  
}


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