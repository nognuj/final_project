resource "aws_sns_topic" "after_approval" {
  name = "after_approval"
}

resource "aws_sns_topic_policy" "gafter_approval_policy" {
  arn    = aws_sns_topic.after_approval.arn
  policy = data.aws_iam_policy_document.after_approval_policy.json
}

data "aws_iam_policy_document" "after_approval_policy" {
  policy_id = "__default_policy_ID9"

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
      aws_sns_topic.after_approval.arn,
    ]

    sid = "__default_statement_ID"
  }
}

resource "aws_sqs_queue" "after_approval_queue" {
  name                      = "after_approval_queue"
  delay_seconds             = 1
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 1
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.after_approval_dlq.arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_policy" "after_approval_queue_policy" {
  queue_url = aws_sqs_queue.after_approval_queue.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          AWS = "*"
        }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.after_approval_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.after_approval.arn
          }
        }
      }
    ]
  })
}



resource "aws_sqs_queue" "after_approval_dlq" {
  name = "after_approval_dlq"
}



resource "aws_sns_topic_subscription" "after_approval_target" {
  topic_arn = "arn:aws:sns:ap-northeast-2:138191045074:after_approval"
  protocol  = "sqs"
  endpoint  = "arn:aws:sqs:ap-northeast-2:138191045074:after_approval_queue"
}