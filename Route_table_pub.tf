# create a Route table for VPC
resource "aws_route_table" "rt_pub" {
  vpc_id = aws_vpc.lastvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lastigw.id
  }

  tags = {
    Name = "terraform-route-table"
  }
}


# route table과 subnet 연결
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.pubSub1.id
  route_table_id = aws_route_table.rt_pub.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.pubSub2.id
  route_table_id = aws_route_table.rt_pub.id
}