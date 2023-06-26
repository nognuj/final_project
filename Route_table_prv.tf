resource "aws_route_table" "rt_prv" {
  vpc_id = aws_vpc.lastvpc.id

  tags = {
    Name = "sprint-prv-route-table"
  }
}

resource "aws_route_table_association" "prvassociation1" {
  subnet_id      = aws_subnet.prvsub1.id
  route_table_id = aws_route_table.rt_prv.id
}

resource "aws_route_table_association" "prvassociation2" {
  subnet_id      = aws_subnet.prvsub2.id
  route_table_id = aws_route_table.rt_prv.id
}

