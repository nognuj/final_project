resource "aws_sns_topic" "payment_attempt" {
  name = "payment_attempt"
}

resource "aws_sns_topic_policy" "payment_attempt_policy" {
  arn    = aws_sns_topic.payment_attempt.arn
  policy = data.aws_iam_policy_document.payment_attempt_policy.json
}

data "aws_iam_policy_document" "payment_attempt_policy" {
  policy_id = "__default_policy_ID3"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        var.account-id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.payment_attempt.arn,
    ]

    sid = "__default_statement_ID"
  }
}

resource "aws_sqs_queue" "payment_attempt_queue" {
  name                      = "payment_attempt_queue"
  delay_seconds             = 1
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 1
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.payment_attempt_dlq.arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_policy" "payment_attempt_queue_policy" {
  queue_url = aws_sqs_queue.payment_attempt_queue.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          AWS = "*"
        }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.payment_attempt_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.payment_attempt.arn
          }
        }
      }
    ]
  })
}



resource "aws_sqs_queue" "payment_attempt_dlq" {
  name = "payment_attempt_dlq"
}

resource "aws_sqs_queue" "etc_error_dlq" {
  name = "etc_error_dlq"
}


resource "aws_sns_topic_subscription" "payment_attempt_sqs_target" {
  topic_arn = "${aws_sns_topic.payment_attempt.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.payment_attempt_queue.arn}"
}