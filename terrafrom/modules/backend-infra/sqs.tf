# # SQS Queue for processing messages from SNS
# resource "aws_sqs_queue" "user_updates_queue" {
#   name                      = "${var.namespace}-${var.env}-user-updates-queue"
  
#   tags = {
#     Environment = var.env
#     Namespace   = var.namespace
#   }
# }

# # Policy document allowing the SNS topic to send messages to the queue
# data "aws_iam_policy_document" "sqs_policy" {
#   statement {
#     sid    = "AllowSNS"
#     effect = "Allow"
#     actions = ["sqs:SendMessage"]
#     principals {
#       type        = "Service"
#       identifiers = ["sns.amazonaws.com"]
#     }
#     resources = [aws_sqs_queue.user_updates_queue.arn]
#     condition {
#       test     = "ArnEquals"
#       variable = "aws:SourceArn"
#       values   = [aws_sns_topic.user_updates_topic.arn]
#     }
#   }
# }

# # SQS Queue Policy to allow SNS to send messages to the queue (this has to be applied after the queue is created)
# resource "aws_sqs_queue_policy" "user_updates_policy" {
#   queue_url = aws_sqs_queue.user_updates_queue.id
#   policy    = data.aws_iam_policy_document.sqs_policy.json
# }

