# create ECR and push images in this repo
resource "aws_ecr_repository" "final_ecr_repo" {
  name = "terraform_funding" 
}

## ecr repo생성은 완료 
## git action에서 images 가져오고 업데이트 하는 부분 구현해야 함.