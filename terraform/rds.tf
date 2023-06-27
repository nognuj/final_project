resource "aws_db_subnet_group" "prvsub1_db_subnet_group" {
  name       = "prvsub1-db-subnet-group"
  subnet_ids  = [
    aws_subnet.pubSub1.id,  # prvsub1 서브넷 ID
    aws_subnet.pubSub2.id,  # prvsub2 서브넷 ID
  ]
} // private이면 어디서도 접근을 못하는데 초기 데이터는 어떻게 넣어주지 // 지금은 일단 pub

resource "aws_db_instance" "prvsub1_rds" {
  identifier              = "terrdb"
  
  allocated_storage    = 30
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  db_name              = "test"
  username             = "admin"
  password             = "12345678"
  vpc_security_group_ids = [aws_security_group.prv_sg.id]
  db_subnet_group_name = aws_db_subnet_group.prvsub1_db_subnet_group.name
  skip_final_snapshot = true
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  publicly_accessible = true // vpc
  backup_retention_period = 30
  # multi_az = true
}

resource "aws_db_instance" "prvsub1_replica_rds" {
  identifier          = "terrdb-readonly"
  replicate_source_db = aws_db_instance.prvsub1_rds.identifier
  storage_type        = "gp2"
  engine              = "mysql"
  engine_version      = "5.7"
  instance_class      = "db.t3.micro"
  # db_subnet_group_name = aws_db_subnet_group.prvsub1_db_subnet_group.name
  # backup_retention_period = 30
  publicly_accessible = false
  vpc_security_group_ids = [aws_security_group.prv_sg.id]
  iam_database_authentication_enabled = true
  # final_snapshot_identifier = "prvsub1-replica-rds-final-snapshot"
  skip_final_snapshot = true
  tags = {
    Name = "prvsub1-replica-rds"
  }
}