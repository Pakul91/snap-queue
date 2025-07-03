locals {
  image_buckets = {
    raw = {
        name        = "${var.namespace}-raw-image-bucket-${var.env}"
        description = "Bucket for raw images"
    },
    processed = {
        name        = "${var.namespace}-processed-image-bucket-${var.env}"
        description = "Bucket for processed images"
    }
  }

  image_queues = {
    raw = {
      name        = "${var.namespace}-raw-image-queue-${var.env}"
      description = "Queue for raw image processing events"
    },
    processed = {
      name        = "${var.namespace}-processed-image-queue-${var.env}"
      description = "Queue for processed image events"
    }
  }

  lambda_image_handlers = {
    raw_image = {
      name        = "${var.namespace}-raw-image-handler-${var.env}"
      description = "Lambda function for processing raw images"
      folder_name = "process-raw-image"
      lambda_layers = [aws_lambda_layer_version.sharp.arn]
      env_variables = {
        ENVIRONMENT = var.env    
        LOG_LEVEL   = "info" 
        RAW_IMAGE_BUCKET_NAME = aws_s3_bucket.image_buckets["raw"].id
        PROCESSED_IMAGE_BUCKET_NAME = aws_s3_bucket.image_buckets["processed"].id
      }

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
          aws_s3_bucket.image_buckets["raw"].arn,
          "${aws_s3_bucket.image_buckets["raw"].arn}/*"
        ]
          },
          {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.image_buckets["processed"].arn,
          "${aws_s3_bucket.image_buckets["processed"].arn}/*"
        ]
          }
        ]
      })
      sqs_queue_key = "raw"
     

    },
    processed_image = {
      name        = "${var.namespace}-processed-image-handler-${var.env}"
      description = "Lambda function for storing processed image data"
      folder_name = "store-image-data"
      lambda_layers = []
      env_variables = {
        ENVIRONMENT = var.env    
        LOG_LEVEL   = "info" 
      }
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
              aws_s3_bucket.image_buckets["processed"].arn,
              "${aws_s3_bucket.image_buckets["processed"].arn}/*"
            ]
          }
          # ,
          # {
          #   Effect = "Allow"
          #   Action = [
          #     "dynamodb:PutItem",
          #     "dynamodb:BatchWriteItem"
          #   ]
          #   Resource = aws_dynamodb_table.image_data_table.arn
          # }
        ]
      })


      sqs_queue_key = "processed"
    }
  }
}