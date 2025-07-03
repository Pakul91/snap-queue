
resource "aws_s3_bucket" "image_buckets" {
  for_each = local.image_buckets

  bucket = each.value.name
  force_destroy = true

  tags = {
    Name        = each.value.name
    Environment = var.env
  }
}

resource "aws_s3_bucket_notification" "image_upload_notifications" {
   for_each =  local.image_buckets

   bucket = aws_s3_bucket.image_buckets[each.key].id
   
   queue {
        events = ["s3:ObjectCreated:*"]
        queue_arn =aws_sqs_queue.image_queues[each.key].arn
    }
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
      aws_s3_bucket.image_buckets["raw"].arn,
      "${aws_s3_bucket.image_buckets["raw"].arn}/*"
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
      aws_s3_bucket.image_buckets["raw"].arn,
      "${aws_s3_bucket.image_buckets["raw"].arn}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = [
        module.lambda_image_handlers["raw_image"].function_execution_role.arn,
      ]
    }
  }
}