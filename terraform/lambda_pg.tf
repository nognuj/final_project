data "aws_region" "current1" {}

data "aws_caller_identity" "current1" {}

resource "aws_lambda_function" "pg_lambda" {
  function_name    = "pg2"
  filename         = data.archive_file.pg_lambda_zip_file.output_path
  source_code_hash = data.archive_file.pg_lambda_zip_file.output_base64sha256
  handler          = "pg-lambda.handler"
  role             = aws_iam_role.pg_lambda_role.arn
  runtime          = "nodejs14.x"
  environment {
     variables = {
      DYNAMO_DB_TABLE_NAME     = aws_dynamodb_table.paymentTransactions.name
      PAYMENT_DLQ              = aws_sqs_queue.payment_attempt_dlq.url
      ETC_DLQ                  = aws_sqs_queue.etc_error_dlq.url
      APPROVE_PAYMENT_TOPIC    = aws_sns_topic.after_approval.arn
      FOR_MAIL                 = aws_sns_topic.payment_result_mailing.arn
    }   
  }
}

data "archive_file" "pg_lambda_zip_file" {
  type        = "zip"
  source_dir  = "${path.module}/../Lambda/pg"
  output_path = "${path.module}/pg_lambda.zip"
}
  

# Role to execute lambda
resource "aws_iam_role" "pg_lambda_role" {
  name               = "pg_lambda_role"
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
resource "aws_cloudwatch_log_group" "pg_lambda_loggroup" {
  name              = "/aws/lambda/${aws_lambda_function.pg_lambda.function_name}"
  retention_in_days = 14
}

# SNS 주제에 대한 SNS Publish 권한을 포함하는 IAM 정책 추가
data "aws_iam_policy_document" "pg_lambda_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      aws_sns_topic.payment_result_mailing.arn,aws_sns_topic.after_approval.arn
    ]
  }
}

# 업데이트된 정책을 IAM 역할에 첨부
resource "aws_iam_role_policy" "pg_lambda_policy_update" {
  name   = "pg_lambda_policy_update"
  role   = aws_iam_role.pg_lambda_role.name
  policy = data.aws_iam_policy_document.pg_lambda_policy_document.json
}



# Custom policy to read SQS queue and write to CloudWatch Logs with least privileges
resource "aws_iam_policy" "pg_lambda_policy" {   
  name        = "pg_lambda_policy"
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
      "Resource": ["${aws_sqs_queue.payment_attempt_queue.arn}","${aws_sqs_queue.etc_error_dlq.arn}","${aws_sqs_queue.payment_attempt_dlq.arn}"]
    },  
    {
      "Effect": "Allow",
      "Action": [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:${data.aws_region.current1.name}:${data.aws_caller_identity.current1.account_id}:log-group:/aws/lambda/${aws_lambda_function.pg_lambda.function_name}:*:*"
    },
     {
            "Effect": "Allow",
            "Action": ["dynamodb:Scan","dynamodb:PutItem"],
            "Resource": "arn:aws:dynamodb:ap-northeast-2:138191045074:table/paymentTransactions2"
        }
  ]
}
EOF
}

# 위에서 작성된 IAM ROLE을 정책에 연결
resource "aws_iam_role_policy_attachment" "pg_lambda_policy_attachment" {
  role       = aws_iam_role.pg_lambda_role.name
  policy_arn = aws_iam_policy.pg_lambda_policy.arn
}

# 이벤트 소스 매핑
resource "aws_lambda_event_source_mapping" "pg_sqs_lambda_source_mapping" {
  event_source_arn = aws_sqs_queue.payment_attempt_queue.arn
  function_name    = aws_lambda_function.pg_lambda.function_name
}


# Lambda 함수에서 SNS로 결과 전송
resource "aws_lambda_function_event_invoke_config" "pg_lambda_event_invoke_config" {
  function_name = aws_lambda_function.pg_lambda.function_name

  destination_config {
    on_success {
      destination = aws_sns_topic.payment_result_mailing.arn
    }
    on_failure {
      destination = aws_sns_topic.payment_result_mailing.arn
    }
  }
}