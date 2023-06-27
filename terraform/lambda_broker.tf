data "aws_region" "current7" {}

data "aws_caller_identity" "current7" {}

resource "aws_lambda_function" "broker_lambda" {
  function_name    = "broker2"
  filename         = data.archive_file.broker_lambda_zip_file.output_path
  source_code_hash = data.archive_file.broker_lambda_zip_file.output_base64sha256
  handler          = "broker-lambda.handler"
  role             = aws_iam_role.broker_lambda_role.arn
  runtime          = "nodejs14.x"
  environment {
     variables = {
      PAYMENT_ATTEMPT_TOPIC_ARN     = aws_sns_topic.payment_attempt.arn
      GOAL_ACHIVEMENT_TOPIC_ARN     = aws_sns_topic.goal_achievement.arn
    }   
  }
}

data "archive_file" "broker_lambda_zip_file" {
  type        = "zip"
  source_dir  = "${path.module}/../Lambda/broker"
  output_path = "${path.module}/broker_lambda.zip"
}
  

# Role to execute lambda
resource "aws_iam_role" "broker_lambda_role" {
  name               = "broker_lambda_role"
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
resource "aws_cloudwatch_log_group" "broker_lambda_loggroup" {
  name              = "/aws/lambda/${aws_lambda_function.broker_lambda.function_name}"
  retention_in_days = 14
}

# SNS 주제에 대한 SNS Publish 권한을 포함하는 IAM 정책 추가
data "aws_iam_policy_document" "broker_lambda_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      aws_sns_topic.payment_attempt.arn,
      aws_sns_topic.goal_achievement.arn
    ]
  }
}

# 업데이트된 정책을 IAM 역할에 첨부
resource "aws_iam_role_policy" "broker_lambda_policy_update" {
  name   = "broker_lambda_policy_update"
  role   = aws_iam_role.broker_lambda_role.name
  policy = data.aws_iam_policy_document.broker_lambda_policy_document.json
}



# Custom policy to read SQS queue and write to CloudWatch Logs with least privileges
resource "aws_iam_policy" "broker_lambda_policy" {   
  name        = "broker_lambda_policy"
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
      "Resource": "arn:aws:logs:${data.aws_region.current7.name}:${data.aws_caller_identity.current7.account_id}:log-group:/aws/lambda/${aws_lambda_function.broker_lambda.function_name}:*:*"
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
resource "aws_iam_role_policy_attachment" "broker_lambda_policy_attachment" {
  role       = aws_iam_role.broker_lambda_role.name
  policy_arn = aws_iam_policy.broker_lambda_policy.arn
}

# Lambda 함수를 호출하는 API Gateway 리소스 정의
resource "aws_api_gateway_rest_api" "my_api_gateway" {
  name        = "my-api-gateway"
  description = "My API Gateway"
}

resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.my_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.my_api_gateway.root_resource_id
  path_part   = "broker"
}

resource "aws_api_gateway_method" "api_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api_gateway.id
  resource_id   = aws_api_gateway_resource.api_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.my_api_gateway.id
  resource_id             = aws_api_gateway_resource.api_resource.id
  http_method             = aws_api_gateway_method.api_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.broker_lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "api_method_response" {
  rest_api_id = aws_api_gateway_rest_api.my_api_gateway.id
  resource_id = aws_api_gateway_resource.api_resource.id
  http_method = aws_api_gateway_method.api_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

# Lambda 함수를 호출하는 API Gateway 엔드포인트 정의
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.api_integration,
    aws_api_gateway_method_response.api_method_response
  ]

  rest_api_id = aws_api_gateway_rest_api.my_api_gateway.id
  stage_name  = "prod"
}

# API Gateway의 엔드포인트를 통해 Lambda 함수 호출
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.broker_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = aws_api_gateway_deployment.api_deployment.execution_arn
}

