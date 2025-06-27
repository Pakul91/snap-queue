resource "aws_sns_topic" "user_updates_topic" {
  name = "${var.namespace}-${var.env}-user-updates-topic"
}

# SNS subscription connecting the topic to the queue
resource "aws_sns_topic_subscription" "user_updates_subscription" {
  topic_arn = aws_sns_topic.user_updates_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.user_updates_queue.arn

  depends_on = [
    aws_sns_topic.user_updates_topic,
    aws_sqs_queue.user_updates_queue
  ]
}