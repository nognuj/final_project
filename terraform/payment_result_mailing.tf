resource "aws_sns_topic" "payment_result_mailing" {
  name = "payment_result_mailing"
}

resource "aws_sns_topic_policy" "payment_result_mailing_policy" {
  arn    = aws_sns_topic.payment_result_mailing.arn
  policy = data.aws_iam_policy_document.payment_result_mailing_policy.json
}

data "aws_iam_policy_document" "payment_result_mailing_policy" {
  policy_id = "__default_policy_ID7"

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
      aws_sns_topic.payment_result_mailing.arn,
    ]

    sid = "__default_statement_ID"
  }
}

resource "aws_sqs_queue" "payment_result_mailing_queue" {
  name                      = "payment_result_mailing_queue"
  delay_seconds             = 1
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 1
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.payment_result_mailing_dlq.arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_policy" "payment_result_mailing_queue_policy" {
  queue_url = aws_sqs_queue.payment_result_mailing_queue.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          AWS = "*"
        }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.payment_result_mailing_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.payment_result_mailing.arn
          }
        }
      }
    ]
  })
}



resource "aws_sqs_queue" "payment_result_mailing_dlq" {
  name = "payment_result_mailing_dlq"
}



resource "aws_sns_topic_subscription" "payment_result_mailing_target" {
  topic_arn = "arn:aws:sns:ap-northeast-2:138191045074:payment_result_mailing"
  protocol  = "sqs"
  endpoint  = "arn:aws:sqs:ap-northeast-2:138191045074:payment_result_mailing_queue"
}