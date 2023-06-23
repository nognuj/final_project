# # aws_ecs_cluster_serivce
resource "aws_ecs_service" "terraform_ecs_serivce" {
  name            = "terraform_ecs_serivce"
  cluster         = aws_ecs_cluster.crowd_cluster.id
  task_definition = aws_ecs_task_definition.terraform_td_funding.arn
  desired_count   = 1
  launch_type = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.terraform_sg.id]
    subnets = [aws_subnet.pubSub1.id, aws_subnet.pubSub2.id]
    assign_public_ip = true
  }
  # iam_role        = aws_iam_role.test_role.arn
  # depends_on      = [aws_iam_role_policy.test_policy]

  # ordered_placement_strategy {
  #   type  = "binpack"
  #   field = "cpu"
  # }

  # load_balancer {
  #   target_group_arn = aws_lb_target_group.alb_tg.arn
  #   container_name   = "mongo"
  #   container_port   = 8080
  # }
}

resource "aws_security_group" "terraform_sg" {
  name        = "terraform_vpc"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.lastvpc.id

  ingress {
    description      = "TCP"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}