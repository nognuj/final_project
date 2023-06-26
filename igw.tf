# create igw
resource "aws_internet_gateway" "lastigw" {
  vpc_id = aws_vpc.lastvpc.id

  tags = {
    Name = "terraform-igw"
  }
}
