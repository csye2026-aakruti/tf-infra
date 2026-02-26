# Load Balancer SG - allow inbound HTTP from Internet
resource "aws_security_group" "lb_sg" {
  name        = "${var.project}-${var.env}-${var.name_suffix}-lb-sg"
  description = "Allow inbound HTTP to ALB"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-${var.name_suffix}-lb-sg"
  }
}

# App SG - allow inbound app port ONLY from LB SG
# App SG - allow inbound traffic for web application
resource "aws_security_group" "app_sg" {
  name        = "${var.project}-${var.env}-${var.name_suffix}-app-sg"
  description = "Allow inbound app traffic from ALB only"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App port from anywhere"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-${var.name_suffix}-app-sg"
  }
}
# DB SG - allow inbound Postgres ONLY from App SG
resource "aws_security_group" "db_sg" {
  name        = "${var.project}-${var.env}-${var.name_suffix}-db-sg"
  description = "Allow inbound Postgres from app only"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "Postgres from app"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-${var.name_suffix}-db-sg"
  }
}