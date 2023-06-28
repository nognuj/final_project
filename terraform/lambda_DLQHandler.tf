data "aws_region" "current5" {}

data "aws_caller_identity" "current5" {}

resource "aws_lambda_function" "DLQHandler_lambda" {
  function_name    = "DLQHandler"
  filename         = data.archive_file.DLQHandler_lambda_zip_file.output_path
  source_code_hash = data.archive_file.DLQHandler_lambda_zip_file.output_base64sha256
  handler          = "dlq-handler-lambda.handler"
  role             = aws_iam_role.DLQHandler_lambda_role.arn
  runtime          = "nodejs14.x"
  environment {
      variables = {
      SEND_EMAIL_QUEUE_URL     = aws_sqs_queue.payment_result_mailing_queue.url
      PAYMENT_QUEUE_URL     = aws_sqs_queue.payment_attempt_dlq.url
      DISCORD_WEB_HOOK_URL:"https://discord.com/api/webhooks/1121115147944083507/_vhVnWFlKlYjFy5gu2K07uR0GHv92qEy7qtBRvqXiJyM_3DS9O3GOPs5JtF5nj9JJEJj"
    }  
  }
}

data "archive_file" "DLQHandler_lambda_zip_file" {
  type        = "zip"
  source_dir  = "${path.module}/../Lambda/DLQHandler"
  output_path = "${path.module}/DLQHandler_lambda.zip"
}
  

# Role to execute lambda
resource "aws_iam_role" "DLQHandler_lambda_role" {
  name               = "DLQHandler_lambda_role"
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
resource "aws_cloudwatch_log_group" "DLQHandler_lambda_loggroup" {
  name              = "/aws/lambda/${aws_lambda_function.DLQHandler_lambda.function_name}"
  retention_in_days = 14
}

# Custom policy to read SQS queue and write to CloudWatch Logs with least privileges
resource "aws_iam_policy" "DLQHandler_lambda_policy" {   
  name        = "DLQHandler_lambda_policy"
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
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": "${aws_sqs_queue.etc_error_dlq.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": "${aws_sqs_queue.payment_result_mailing_dlq.arn}"
    },{
      "Effect": "Allow",
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": "${aws_sqs_queue.payment_attempt_dlq.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:${data.aws_region.current5.name}:${data.aws_caller_identity.current5.account_id}:log-group:/aws/lambda/${aws_lambda_function.DLQHandler_lambda.function_name}:*:*"
    }
  ]
}
EOF
}

# 위에서 작성된 IAM ROLE을 정책에 연결
resource "aws_iam_role_policy_attachment" "DLQHandler_lambda_policy_attachment" {
  role       = aws_iam_role.DLQHandler_lambda_role.name
  policy_arn = aws_iam_policy.DLQHandler_lambda_policy.arn
}

# 이벤트 소스 매핑
resource "aws_lambda_event_source_mapping" "DLQHandler_sqs_lambda_source_mapping" {
  event_source_arn = aws_sqs_queue.etc_error_dlq.arn
  function_name    = aws_lambda_function.DLQHandler_lambda.function_name
}


resource "aws_lambda_event_source_mapping" "payment_result_mailing_dlq_lambda_source_mapping" {
  event_source_arn = aws_sqs_queue.payment_result_mailing_dlq.arn
  function_name    = aws_lambda_function.DLQHandler_lambda.function_name
}

resource "aws_lambda_event_source_mapping" "payment_attempt_dlq_lambda_source_mapping" {
  event_source_arn = aws_sqs_queue.payment_attempt_dlq.arn
  function_name    = aws_lambda_function.DLQHandler_lambda.function_name
}