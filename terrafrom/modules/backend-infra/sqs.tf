# # SQS Queue for processing messages from SNS
resource "aws_sqs_queue" "image_processing_queue" {
  name                      = "${var.namespace}-image-processing-queue-${var.env}"
  
  tags = {
    Environment = var.env
    Namespace   = var.namespace
  }
}

# Policy document allowing the S3 bucket to send messages to the SQS queue
data "aws_iam_policy_document" "image_processing_queue_policy" {
  statement {
    sid    = "AllowS3ToSendMessages"
    effect = "Allow"
    actions = ["sqs:SendMessage"]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    resources = [aws_sqs_queue.image_processing_queue.arn]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.raw_image_bucket.arn]
    }
  }
}

# SQS Queue Policy to allow SNS to send messages to the queue (this has to be applied after the queue is created)
resource "aws_sqs_queue_policy" "image_processing_queue_policy" {
  queue_url = aws_sqs_queue.image_processing_queue.id
  policy    = data.aws_iam_policy_document.image_processing_queue_policy.json
}

