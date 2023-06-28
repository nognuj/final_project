data "aws_region" "current3" {}

data "aws_caller_identity" "current3" {}

resource "aws_lambda_function" "email_lambda" {
  function_name    = "sendEmail2"
  filename         = data.archive_file.email_lambda_zip_file.output_path
  source_code_hash = data.archive_file.email_lambda_zip_file.output_base64sha256
  handler          = "send-email-lambda.handler"
  role             = aws_iam_role.email_lambda_role.arn
  runtime          = "nodejs14.x"
  environment {
    variables = {
      LAMBDA_REGION     = data.aws_region.current3.name
      SES_REGION     = data.aws_region.current3.name
      SES_SENDER     = "dnehgus6975@gmail.com"  # 이메일 발신자 주소
      SES_RECIPIENT  = "dnehgus0987@naver.com"  # 이메일 수신자 주소
    }
  }
}

data "archive_file" "email_lambda_zip_file" {
  type        = "zip"
  source_dir  = "${path.module}/../Lambda/sendEmail"
  output_path = "${path.module}/email_lambda.zip"
}
  

# Role to execute lambda
resource "aws_iam_role" "email_lambda_role" {
  name               = "email_lambda_role"
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
resource "aws_cloudwatch_log_group" "email_lambda_loggroup" {
  name              = "/aws/lambda/${aws_lambda_function.email_lambda.function_name}"
  retention_in_days = 14
}

# Custom policy to read SQS queue and write to CloudWatch Logs with least privileges
resource "aws_iam_policy" "email_lambda_policy" {   
  name        = "email_lambda_policy"
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
      "Resource": "${aws_sqs_queue.payment_result_mailing_queue.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:${data.aws_region.current3.name}:${data.aws_caller_identity.current3.account_id}:log-group:/aws/lambda/${aws_lambda_function.email_lambda.function_name}:*:*"
    }
  ]
}
EOF
}

# SES를 사용하기 위한 권한을 추가한 IAM 정책
resource "aws_iam_policy" "email_lambda_ses_policy" {
  name        = "email_lambda_ses_policy"
  path        = "/"
  description = "Policy for sending email using SES"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ses:SendEmail",
      "Resource": "*"
    }
  ]
}
EOF
}

# IAM 역할에 SES 정책 첨부
resource "aws_iam_role_policy_attachment" "email_lambda_ses_policy_attachment" {
  role       = aws_iam_role.email_lambda_role.name
  policy_arn = aws_iam_policy.email_lambda_ses_policy.arn
}

# 위에서 작성된 IAM ROLE을 정책에 연결
resource "aws_iam_role_policy_attachment" "mail_lambda_policy_attachment" {
  role       = aws_iam_role.email_lambda_role.name
  policy_arn = aws_iam_policy.email_lambda_policy.arn
}

# 이벤트 소스 매핑
resource "aws_lambda_event_source_mapping" "sqs_mail_lambda_source_mapping" {
  event_source_arn = aws_sqs_queue.payment_result_mailing_queue.arn
  function_name    = aws_lambda_function.email_lambda.function_name
}
