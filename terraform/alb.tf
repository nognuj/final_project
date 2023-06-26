
resource "aws_alb" "terra_alb" {
    name = "terra-alb"
    subnets = [aws_subnet.pubSub1.id, aws_subnet.pubSub2.id]
    security_groups =  [aws_security_group.terraform_sg.id]
}

# // 이게 총 3개!
resource "aws_alb_target_group" "alb_target_group_funding" {
    name = "funding-tg"
    port = 3000
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = aws_vpc.lastvpc.id

    health_check {
      healthy_threshold = 2
      unhealthy_threshold = 2
      timeout = 3
      protocol = "HTTP"
      matcher = "200"
      path = "/"
      interval = 30
    }
}

resource "aws_alb_listener" "alb_listener_funding" {
  load_balancer_arn = aws_alb.terra_alb.id
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    //추가 적인 뭔가 더 있어야 될듯
    target_group_arn = aws_alb_target_group.alb_target_group_funding.arn
  }
}