# aws_ecs_cluster_serivce
resource "aws_ecs_service" "ecs_serivce" {
  name            = "ecs_serivce"
  cluster         = aws_ecs_cluster.crowd_cluster.id
  task_definition = aws_ecs_task_definition.ecs_td_crowd.arn
  desired_count   = 3
  iam_role        = aws_iam_role.test_role.arn
  depends_on      = [aws_iam_role_policy.test_policy]

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    container_name   = "mongo"
    container_port   = 8080
  }
}
