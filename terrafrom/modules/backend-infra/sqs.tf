# SQS Queues for processing messages from S3 events
resource "aws_sqs_queue" "image_queues" {
  for_each = local.image_queues
  
  name = each.value.name
  
  tags = {
    Environment = var.env
    Namespace   = var.namespace
    Description = each.value.description
    Type        = "${each.key}_image_queue"
  }
}

# Policy documents allowing S3 buckets to send messages to their respective SQS queues
data "aws_iam_policy_document" "queue_policies" {
  for_each = local.image_queues
  
  statement {
    sid    = "AllowS3ToSendMessages"
    effect = "Allow"
    actions = ["sqs:SendMessage"]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    resources = [aws_sqs_queue.image_queues[each.key].arn]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [
        aws_s3_bucket.image_buckets[each.key].arn
      ]
    }
  }
}

# SQS Queue Policies to allow S3 to send messages to the queues
resource "aws_sqs_queue_policy" "queue_policies" {
  for_each  = local.image_queues
  
  queue_url = aws_sqs_queue.image_queues[each.key].id
  policy    = data.aws_iam_policy_document.queue_policies[each.key].json
}

