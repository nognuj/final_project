# RDS 생성
resource "aws_db_subnet_group" "prvsub1_db_subnet_group" {
  name       = "prvsub1-db-subnet-group"
  subnet_ids  = [
    aws_subnet.prvsub1.id,  # prvsub1 서브넷 ID
    aws_subnet.prvsub2.id,  # prvsub2 서브넷 ID
  ]
}

resource "aws_db_instance" "prvsub1_rds" {
  allocated_storage    = 30
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  db_name              = "prvsub1_rds"
  username             = "admin"
  password             = "team08!!"
  db_subnet_group_name = aws_db_subnet_group.prvsub1_db_subnet_group.name
}


resource "aws_db_subnet_group" "prvsub2_db_subnet_group" {
  name       = "prvsub2-db-subnet-group"
  subnet_ids  = [
    aws_subnet.prvsub1.id,  # prvsub1 서브넷 ID
    aws_subnet.prvsub2.id,  # prvsub2 서브넷 ID
  ]
}

resource "aws_db_instance" "prvsub2_rds" {
  allocated_storage    = 30
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  db_name              = "prvsub2_rds"
  username             = "admin"
  password             = "team08!!"
  db_subnet_group_name = aws_db_subnet_group.prvsub2_db_subnet_group.name
  publicly_accessible = false
  iam_database_authentication_enabled = true
  final_snapshot_identifier = "prvsub2-rds-final-snapshot"
  skip_final_snapshot = true
  tags = {
    Name = "prvsub2-rds"
  }
}
