# create ECS cluster 
resource "aws_ecs_cluster" "crowd_cluster" {
  name = "crwod-cluster" 
}