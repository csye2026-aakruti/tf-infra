# Custom parameter group (required by assignment)
resource "aws_db_parameter_group" "postgres" {
  name        = "${var.project}-${var.env}-${var.name_suffix}-pg16"
  family      = "postgres16"
  description = "Custom parameter group for PostgreSQL 16"

  tags = {
    Name = "${var.project}-${var.env}-${var.name_suffix}-pg16"
  }
}

# DB subnet group - uses private subnets
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.project}-${var.env}-${var.name_suffix}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project}-${var.env}-${var.name_suffix}-db-subnet-group"
  }
}

# RDS instance
resource "aws_db_instance" "postgres" {
  identifier        = "csye6225"
  engine            = "postgres"
  engine_version    = "16"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "csye6225"
  username = "csye6225"
  password = var.db_master_password

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  parameter_group_name   = aws_db_parameter_group.postgres.name

  publicly_accessible = false
  skip_final_snapshot = true
  multi_az            = false
  storage_encrypted   = true
  kms_key_id          = aws_kms_key.rds.arn

  tags = {
    Name = "${var.project}-${var.env}-${var.name_suffix}-postgres"
  }
}