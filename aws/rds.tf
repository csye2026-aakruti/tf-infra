resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.project}-${var.env}-${var.name_suffix}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project}-${var.env}-${var.name_suffix}-db-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier        = "${var.project}-${var.env}-${var.name_suffix}-postgres"
  engine            = "postgres"
  engine_version    = "16"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_master_password

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  publicly_accessible = false
  skip_final_snapshot = true
  multi_az            = false

  tags = {
    Name = "${var.project}-${var.env}-${var.name_suffix}-postgres"
  }
}