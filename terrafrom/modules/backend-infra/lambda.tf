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

