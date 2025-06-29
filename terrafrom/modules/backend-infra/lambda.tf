module "process_raw_image_lambda" {
    source = "./composables/lambda/"
    lambda_function_name = "process-raw-image-handler-${var.env}"
    lambda_folder_name = "process-raw-image"
    env = var.env
    namespace = var.namespace
    env_variables = {
        ENVIRONMENT = var.env    
        LOG_LEVEL   = "info" 
        RAW_IMAGE_BUCKET_NAME = aws_s3_bucket.raw_image_bucket.id
    }
    tags = {
        Environment = var.env
        Application = var.namespace  
    }
}

resource "aws_iam_policy" "s3_raw_image_access" {
  name     = "${module.process_raw_image_lambda.function_name}-s3-access-policy"
  path        = "/"
  description = "IAM policy for accessing raw image S3 bucket in the ${var.env} environment"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.raw_image_bucket.arn,
          "${aws_s3_bucket.raw_image_bucket.arn}/*"
        ]
      }
    ]
  })     
}

# SQS permissions for the Lambda function
resource "aws_iam_policy" "sqs_permission_for_lambda" {
  name        = "${module.process_raw_image_lambda.function_name}-sqs-policy"
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
        Resource = aws_sqs_queue.image_processing_queue.arn
      }
    ]
  })
}

# Attach the SQS policy to the Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_sqs_policy_attachment" {
  role       = module.process_raw_image_lambda.function_execution_role.name
  policy_arn = aws_iam_policy.sqs_permission_for_lambda.arn
}

# Attach the S3 policy to the Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  role       = module.process_raw_image_lambda.function_execution_role.name
  policy_arn = aws_iam_policy.s3_raw_image_access.arn
}

resource "aws_lambda_event_source_mapping" "lambda_sqs_event_source" {
  event_source_arn = aws_sqs_queue.image_processing_queue.arn
  enabled          = true
  function_name    = module.process_raw_image_lambda.function_name
  batch_size       = 10

  scaling_config {
    maximum_concurrency = 100
  }
}
