# aws_ecs_task_definition

// 이건 왜 안 되지?
#   container_definitions = file("funding_td.json")
// 다음에 image보고 > 해볼려했는데 이상한 오류가 남
# data "template_file" "testapp" {
#   template =  file("funding_td.json")

#   vars = {
#     app_image = "997059781683.dkr.ecr.ap-northeast-2.amazonaws.com/terraform_funding:latest"
#     app_port = 3000
#     fargate_cpu = 1024
#     fargate_memory = 3048
#     aws_region = "ap-northeast-2"
#   }
# }

resource "aws_ecs_task_definition" "terraform_td_funding" {
  family                   = "terraform_funding_td"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  # container_definitions    = data.template_file.testapp.rendered
  container_definitions    = <<TASK_DEFINITION
  [
    {
      "name": "funding_ct",
      "image": "997059781683.dkr.ecr.ap-northeast-2.amazonaws.com/terraform_funding:latest",
      "portMappings": [
        {
          "name": "funding_ct-3000-tcp",
          "containerPort": 3000,
          "hostPort": 3000,
          "protocol": "tcp",
          "appProtocol": "http"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-create-group": "true",
          "awslogs-group": "/ecs/terraform_td_funding",
          "awslogs-region": "ap-northeast-2",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
  TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

}

data "aws_iam_policy_document" "ecs_task_execution_role" {
    version = "2012-10-17"
    statement {
      sid = ""
      effect   = "Allow"
      actions = [ "sts:AssumeRole" ]
      principals {
        type = "Service"
        identifiers = ["ecs-tasks.amazonaws.com"]
      }
  }  
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "myECcsTaskEcecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

// cloudwatch 붙이기! > 뭔가 독립적으로 연결을 하는 구나 알아서 찾아서 연결
// 지표수집으로 프로메테우스에다가도 붙일 수 있단
# cloudwatch 연결해야되는 부분이 있어야 될거 같은데 없어 보임

resource "aws_cloudwatch_log_group" "testapp_log_group" {
  name = "/ecs/terraform_td_funding"
  retention_in_days = 30

  # tags = {
  #   Name = "cw-log-group-terraform_td_funding"
  # }
}


# 이 부분이 굳이 없어도 자동으로 생성시켜주는 것 같음
# resource "aws_cloudwatch_log_stream" "myapp_log_stream" {
#   name = "terraform_td_funding-stream"
#   log_group_name =  aws_cloudwatch_log_group.testapp_log_group.name
# }

#  암호화는 이거 비스무리하게한다
# resource "aws_secretsmanager_secret_version" "test" {
#   secret_id     = aws_secretsmanager_secret.test.id
#   secret_string = jsonencode({ username : "admin", password : aws_directory_service_directory.test.password })
# }



resource "aws_ecs_task_definition" "terraform_td_funding_rw" {
  family                   = "terraform_funding_rw_td"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  # container_definitions    = data.template_file.testapp.rendered
  container_definitions    = <<TASK_DEFINITION
  [
    {
      "name": "funding_rw_ct",
      "image": "997059781683.dkr.ecr.ap-northeast-2.amazonaws.com/terraform_funding_read_write:latest",
      "portMappings": [
        {
          "name": "funding_rw_ct-3000-tcp",
          "containerPort": 3000,
          "hostPort": 3000,
          "protocol": "tcp",
          "appProtocol": "http"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-create-group": "true",
          "awslogs-group": "/ecs/terraform_td_funding_rw",
          "awslogs-region": "ap-northeast-2",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
  TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

}


resource "aws_cloudwatch_log_group" "testapp_log_group2" {
  name = "/ecs/terraform_td_funding_rw"
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "terraform_td_pay" {
  family                   = "terraform_pay"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  # container_definitions    = data.template_file.testapp.rendered
  container_definitions    = <<TASK_DEFINITION
  [
    {
      "name": "pay_ct",
      "image": "997059781683.dkr.ecr.ap-northeast-2.amazonaws.com/terraform_payment:latest",
      "portMappings": [
        {
          "name": "pay_ct-3000-tcp",
          "containerPort": 3000,
          "hostPort": 3000,
          "protocol": "tcp",
          "appProtocol": "http"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-create-group": "true",
          "awslogs-group": "/ecs/terraform_td_pay",
          "awslogs-region": "ap-northeast-2",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
  TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

}


resource "aws_cloudwatch_log_group" "testapp_log_group3" {
  name = "/ecs/terraform_td_pay"
  retention_in_days = 30
}