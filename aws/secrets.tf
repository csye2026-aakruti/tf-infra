resource "aws_secretsmanager_secret" "db_password" {
  name       = "${var.project}-${var.env}-${var.name_suffix}-db-password"
  kms_key_id = aws_kms_key.secrets.arn

  tags = {
    Name = "${var.project}-${var.env}-${var.name_suffix}-db-password"
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    password = var.db_master_password
  })
}

resource "aws_secretsmanager_secret" "mailgun_credentials" {
  name       = "${var.project}-${var.env}-${var.name_suffix}-mailgun"
  kms_key_id = aws_kms_key.secrets.arn

  tags = {
    Name = "${var.project}-${var.env}-${var.name_suffix}-mailgun"
  }
}

resource "aws_secretsmanager_secret_version" "mailgun_credentials" {
  secret_id = aws_secretsmanager_secret.mailgun_credentials.id
  secret_string = jsonencode({
    api_key = var.mailgun_api_key
    domain  = var.mailgun_domain
  })
}