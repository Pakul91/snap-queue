
module "lambda_image_handlers" {
    for_each = local.lambda_image_handlers

    source = "./composables/lambda/"
    lambda_function_name = each.value.name
    lambda_folder_name = each.value.folder_name
    lambda_layers= each.value.lambda_layers
    env = var.env
    namespace = var.namespace
    env_variables = each.value.env_variables

    tags = {
        Environment = var.env
        Application = var.namespace  
    }
}

# SQS permissions for the Lambda function
resource "aws_iam_policy" "sqs_permission_for_lambdas" {
  for_each = local.lambda_image_handlers

  name        = "${module.lambda_image_handlers[each.key].function_name}-sqs-policy"
  description = "Allow Lambda to receive messages from SQS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = aws_sqs_queue.image_queues[each.value.sqs_queue_key].arn
      }
    ]
  })
}

# Attach the SQS policy to the Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_sqs_policy_attachment" {
  for_each = local.lambda_image_handlers
  role       = module.lambda_image_handlers[each.key].function_execution_role.name
  policy_arn = aws_iam_policy.sqs_permission_for_lambdas[each.key].arn
}

resource "aws_lambda_event_source_mapping" "lambda_sqs_event_source" {
  for_each = local.lambda_image_handlers
  event_source_arn = aws_sqs_queue.image_queues[each.value.sqs_queue_key].arn
  enabled          = true
  function_name    = module.lambda_image_handlers[each.key].function_name
  batch_size       = 10

  scaling_config {
    maximum_concurrency = 100
  }
}

# S3 read access policy for Lambda functions
resource "aws_iam_policy" "s3_read_access" {
  for_each = local.lambda_image_handlers
  name     = "${module.lambda_image_handlers[each.key].function_name}-access-policy"
  path        = "/"
  description = "IAM policy for Lambda to access S3 buckets"
  policy = each.value.policy   
}

# Attach the S3 policy to the Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachments" {
  for_each = local.lambda_image_handlers
  role       = module.lambda_image_handlers[each.key].function_execution_role.name
  policy_arn = aws_iam_policy.s3_read_access[each.key].arn
}



# Lambda later for sharp library - use from external package:
# https://github.com/cbschuld/sharp-aws-lambda-layer?tab=readme-ov-file
resource "aws_lambda_layer_version" "sharp" {
  filename    = "../packages/libs/sharp-layer/release-x64.zip"
  layer_name  = "sharpLayer"
  description = "Provides the sharp library as a layer"

  compatible_runtimes      = ["nodejs22.x"]
  compatible_architectures = ["x86_64"]
}




