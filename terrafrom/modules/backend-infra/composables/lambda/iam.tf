
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


