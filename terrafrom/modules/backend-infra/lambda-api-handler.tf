

module "api_handler_lambda" {
  source = "./composables/lambda/"

  lambda_function_name = local.api_handler_lambda_name
  lambda_folder_name = local.api_handler_lambda_folder
  env = var.env

  env_variables = {
    ENVIRONMENT = var.env
    LOG_LEVEL   = "info"
  }


  tags = {
    Environment = var.env
    Application = var.namespace
  }
}

 
# SNS Publish Policy - Grants Lambda permission to publish to SNS
resource "aws_iam_policy" "lambda_sns_publish" {
  name        = "${local.api_handler_lambda_name}-sns-publish"
  description = "Allows Lambda to publish messages to SNS topics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = aws_sns_topic.user_updates_topic.arn
      }
    ]
  })

  depends_on = [module.api_handler_lambda]
}

# Attach SNS policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_sns" {
  role       = module.api_handler_lambda.function_execution_role.name
  policy_arn = aws_iam_policy.lambda_sns_publish.arn
}


