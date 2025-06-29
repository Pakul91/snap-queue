locals {
    raw_image_bucket_name = "${var.namespace}-raw-images-${var.env}"
}

resource "aws_s3_bucket" "raw_image_bucket" {
  bucket = local.raw_image_bucket_name
  force_destroy = true

  tags = {
    Name        = local.raw_image_bucket_name
    Environment = var.env
  }
}

resource "aws_s3_bucket_notification" "raw_image_upload_notification" {
    bucket = aws_s3_bucket.raw_image_bucket.id
   
   queue {
        events = ["s3:ObjectCreated:*"]
        queue_arn = aws_sqs_queue.image_processing_queue.arn
    }

    depends_on = [
        aws_sqs_queue_policy.image_processing_queue_policy
    ]
}

data "aws_iam_policy_document" "allow_s3_access_from_lambda" {
  statement {
    sid     = "AllowWriteAccessToLambdas"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]

    resources = [
      aws_s3_bucket.raw_image_bucket.arn,
      "${aws_s3_bucket.raw_image_bucket.arn}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = [
        module.upload_request_endpoint.lambda_execution_role_arn,
      ]
    }
  }

  statement {
    sid     = "AllowReadAccessToLambdas"
    effect  = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl"
    ]

    resources = [
      aws_s3_bucket.raw_image_bucket.arn,
      "${aws_s3_bucket.raw_image_bucket.arn}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = [
        module.process_raw_image_lambda.lambda_execution_role_arn,
      ]
  }
}