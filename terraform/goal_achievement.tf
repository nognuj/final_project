resource "aws_sns_topic" "goal_achievement" {
  name = "goal_achievement"
}

resource "aws_sns_topic_policy" "goal_achievement_policy" {
  arn    = aws_sns_topic.goal_achievement.arn
  policy = data.aws_iam_policy_document.goal_achievement_policy.json
}

data "aws_iam_policy_document" "goal_achievement_policy" {
  policy_id = "__default_policy_ID8"

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
      aws_sns_topic.goal_achievement.arn,
    ]

    sid = "__default_statement_ID"
  }
}

resource "aws_sqs_queue" "goal_achievement_queue" {
  name                      = "goal_achievement_queue"
  delay_seconds             = 1
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 1
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.goal_achievement_dlq.arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_policy" "goal_achievement_queue_policy" {
  queue_url = aws_sqs_queue.goal_achievement_queue.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          AWS = "*"
        }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.goal_achievement_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.goal_achievement.arn
          }
        }
      }
    ]
  })
}



resource "aws_sqs_queue" "goal_achievement_dlq" {
  name = "goal_achievement_dlq"
}



resource "aws_sns_topic_subscription" "goal_achievement_target" {
  topic_arn = "${aws_sns_topic.goal_achievement.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.goal_achievement_queue.arn}"
}