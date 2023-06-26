# create pub subs for fargate tasks
resource "aws_subnet" "pubSub1" {
  vpc_id     = aws_vpc.lastvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"

  // 인스턴스에 공용 IP 주소를 할당해야 함
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-01-for-funding-fargate"
  }
}
resource "aws_subnet" "pubSub2" {
  vpc_id     = aws_vpc.lastvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2c"

  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-02-for-funding-fargate"
  } 
}