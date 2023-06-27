data "aws_region" "current4" {}

data "aws_caller_identity" "current4" {}

resource "aws_lambda_function" "fundingUpdate_lambda" {
  function_name    = "fundingUpdate2"
  filename         = data.archive_file.fundingupdate_lambda_zip_file.output_path
  source_code_hash = data.archive_file.fundingupdate_lambda_zip_file.output_base64sha256
  handler          = "funding-update-lambda.handler"
  role             = aws_iam_role.fundingUpdate_lambda_role.arn
  runtime          = "nodejs14.x"
  environment {
    
  }
}

data "archive_file" "fundingupdate_lambda_zip_file" {
  type        = "zip"
  source_dir  = "${path.module}/../Lambda/fundingUpdate"
  output_path = "${path.module}/fundingUpdate_lambda.zip"
}
  

# Role to execute lambda
resource "aws_iam_role" "fundingUpdate_lambda_role" {
  name               = "fundingUpdate_lambda_role"
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
resource "aws_cloudwatch_log_group" "fundingUpdate_lambda_loggroup" {
  name              = "/aws/lambda/${aws_lambda_function.fundingUpdate_lambda.function_name}"
  retention_in_days = 14
}

# Custom policy to read SQS queue and write to CloudWatch Logs with least privileges
resource "aws_iam_policy" "fundingUpdate_lambda_policy" {   
  name        = "fundingUpdate_lambda_policy"
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
      "Resource": "${aws_sqs_queue.after_approval_queue.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:${data.aws_region.current4.name}:${data.aws_caller_identity.current4.account_id}:log-group:/aws/lambda/${aws_lambda_function.fundingUpdate_lambda.function_name}:*:*"
    }
  ]
}
EOF
}

# 위에서 작성된 IAM ROLE을 정책에 연결
resource "aws_iam_role_policy_attachment" "fundingUpdate_lambda_policy_attachment" {
  role       = aws_iam_role.fundingUpdate_lambda_role.name
  policy_arn = aws_iam_policy.fundingUpdate_lambda_policy.arn
}

# 이벤트 소스 매핑
resource "aws_lambda_event_source_mapping" "fundingUpdate_sqs_lambda_source_mapping" {
  event_source_arn = aws_sqs_queue.after_approval_queue.arn
  function_name    = aws_lambda_function.fundingUpdate_lambda.function_name
}
