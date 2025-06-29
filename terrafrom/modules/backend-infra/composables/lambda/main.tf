/**
  * Terraform module for AWS Lambda function deployment
  * This module sets up a Lambda function with necessary IAM roles, policies, and CloudWatch logging.
 */


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


# Lambda execution role - Provides AWS Lambda permission to run code and access AWS services
# This role establishes the base trust relationship allowing Lambda to assume the role
resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.lambda_function_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}


# CloudWatch Logs policy - Grants permissions needed for Lambda to write to CloudWatch Logs
# This policy enables Lambda to create log groups, streams, and put log events for monitoring
resource "aws_iam_policy" "lambda_logging" {

  name        = "${var.lambda_function_name}-logging"
  path        = "/"
  description = "IAM policy for logging from Lambda function ${var.lambda_function_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:*:*:log-group:/aws/lambda/${var.lambda_function_name}",
          "arn:aws:logs:*:*:log-group:/aws/lambda/${var.lambda_function_name}:*"
        ]
      }
    ]
  })

  tags = var.tags
}

# Attach logging policy to Lambda role - Associates the logging permissions with Lambda execution role
# This enables the Lambda function to write logs to CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}



