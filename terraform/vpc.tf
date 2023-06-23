# create vpc
resource "aws_vpc" "lastvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "last-vpc"
  }
}

# create igw
resource "aws_internet_gateway" "lastigw" {
  vpc_id = aws_vpc.lastvpc.id

  tags = {
    Name = "internet-gateway"
  }
}

# create a Route table for VPC
resource "aws_route_table" "rt_pub" {
  vpc_id = aws_vpc.lastvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lastigw.id
  }

  tags = {
    Name = "last-rt"
  }
}

# create pub subs for fargate tasks
resource "aws_subnet" "pubSub1" {
  vpc_id     = aws_vpc.lastvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-01-for-funding-fargate"
  }
}

resource "aws_subnet" "pubSubt2" {
  vpc_id     = aws_vpc.lastvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-02-for-funding-fargate"
  } 
}

# create private subs for RDS
resource "aws_subnet" "privateSubnet1" {
  vpc_id     = aws_vpc.lastvpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "private-subnet-01-for-funding-RDS"
  }
}

resource "aws_subnet" "privateSubnet2" {
  vpc_id     = aws_vpc.lastvpc.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "private-subnet-02-for-funding-RDS"
  }
}


