#create private subs for RDS
resource "aws_subnet" "prvsub1" {
  vpc_id     = aws_vpc.lastvpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "private-subnet-01-for-funding-RDS"
  }
}

resource "aws_subnet" "prvsub2" {
  vpc_id     = aws_vpc.lastvpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "private-subnet-02-for-funding-RDS"
  }
}