
resource "aws_alb" "terra_alb" {
    name = "terra-alb"
    subnets = [aws_subnet.pubSub1.id, aws_subnet.pubSub2.id]
    security_groups =  [aws_security_group.terraform_sg.id]
}

# # // 이게 총 3개!
resource "aws_alb_target_group" "alb_target_group_funding" {
    name = "funding-tg"
    port = 3000 // 80이 맞지 않나? 구성
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

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.terra_alb.id
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_alb_target_group.alb_target_group_funding_rw.arn
        weight = 50
      }

      target_group {
        arn    = aws_alb_target_group.alb_target_group_funding.arn
        weight = 50
      }
    }
  }
}

resource "aws_alb_target_group" "alb_target_group_funding_rw" {
    name = "funding-rw-tg"
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

resource "aws_lb_listener_rule" "alb_funding_post_rule" {
  listener_arn = aws_alb_listener.alb_listener.arn
  priority     = 1

  action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_alb_target_group.alb_target_group_funding_rw.arn
        weight = 50
      }

      target_group {
        arn    = aws_alb_target_group.alb_target_group_funding.arn
        weight = 50
      }
    }
  }


  condition {
    path_pattern {
    #   values = ["/api/funding"]
      values = ["/funding"]
    }
  }
}

resource "aws_lb_listener_rule" "alb_funding_rw_post_rule" {
  listener_arn = aws_alb_listener.alb_listener.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_target_group_funding_rw.arn
  }

  condition {
    http_request_method {
        values = ["POST"]
    }
  }
}

resource "aws_alb_target_group" "alb_target_group_pay" {
    name = "pay-tg"
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

resource "aws_lb_listener_rule" "alb_payment_rule" {
  listener_arn = aws_alb_listener.alb_listener.arn
  priority     = 3

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_target_group_pay.arn
  }


  condition {
    path_pattern {
    #   values = ["/api/payment"]
      values = ["/payment"]
    }
  }
}