data "aws_region" "current8" {}

data "aws_caller_identity" "current8" {}

resource "aws_lambda_function" "transaction_lambda" {
  function_name    = "transaction2"
  filename         = data.archive_file.transaction_lambda_zip_file.output_path
  source_code_hash = data.archive_file.transaction_lambda_zip_file.output_base64sha256
  handler          = "transaction-lambda.handler"
  role             = aws_iam_role.transaction_lambda_role.arn
  runtime          = "nodejs14.x"
  environment {
     variables = {
      PAYMENT_ATTEMPT_TOPIC_ARN     = aws_sns_topic.payment_attempt.arn
    }   
  }
}

data "archive_file" "transaction_lambda_zip_file" {
  type        = "zip"
  source_dir  = "${path.module}/../Lambda/transactionCheck"
  output_path = "${path.module}/transaction_lambda.zip"
}
  

# Role to execute lambda
resource "aws_iam_role" "transaction_lambda_role" {
  name               = "transaction_lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# CloudWatch Log group to store Lambda logs
resource "aws_cloudwatch_log_group" "transaction_lambda_loggroup" {
  name              = "/aws/lambda/${aws_lambda_function.transaction_lambda.function_name}"
  retention_in_days = 14
}

# SNS 주제에 대한 SNS Publish 권한을 포함하는 IAM 정책 추가
data "aws_iam_policy_document" "transaction_lambda_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      aws_sns_topic.payment_attempt.arn,aws_sns_topic.goal_achievement.arn,aws_sns_topic.after_approval.arn
    ]
  }
}

# 업데이트된 정책을 IAM 역할에 첨부
resource "aws_iam_role_policy" "transaction_lambda_policy_update" {
  name   = "transaction_lambda_policy_update"
  role   = aws_iam_role.transaction_lambda_role.name
  policy = data.aws_iam_policy_document.transaction_lambda_policy_document.json
}



# Custom policy to read SQS queue and write to CloudWatch Logs with least privileges
resource "aws_iam_policy" "transaction_lambda_policy" {   
  name        = "transaction_lambda_policy"
  path        = "/"
  description = "Policy for sqs to lambda demo"
  policy      = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect": "Allow",
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:sendmessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": ["${aws_sqs_queue.payment_attempt_queue.arn}","${aws_sqs_queue.etc_error_dlq.arn}","${aws_sqs_queue.payment_attempt_dlq.arn}","${aws_sqs_queue.goal_achievement_queue.arn}","${aws_sqs_queue.goal_achievement_dlq.arn}"]
    },  
    {
      "Effect": "Allow",
      "Action": [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:${data.aws_region.current8.name}:${data.aws_caller_identity.current8.account_id}:log-group:/aws/lambda/${aws_lambda_function.transaction_lambda.function_name}:*:*"
    },
     {
            "Effect": "Allow",
            "Action": ["dynamodb:Scan","dynamodb:PutItem"],
            "Resource": "${aws_dynamodb_table.paymentTransactions.arn}"
        }
  ]
}
EOF
}

# 위에서 작성된 IAM ROLE을 정책에 연결
resource "aws_iam_role_policy_attachment" "transaction_lambda_policy_attachment" {
  role       = aws_iam_role.transaction_lambda_role.name
  policy_arn = aws_iam_policy.transaction_lambda_policy.arn
}

# 이벤트 소스 매핑
resource "aws_lambda_event_source_mapping" "transaction_sqs_lambda_source_mapping" {
  event_source_arn = aws_sqs_queue.goal_achievement_queue.arn
  function_name    = aws_lambda_function.transaction_lambda.function_name
}
