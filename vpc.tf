# create vpc
resource "aws_vpc" "lastvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "terraform-vpc"
  }
}
