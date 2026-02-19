resource "aws_instance" "app" {
  ami                         = var.custom_ami_id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.main.key_name
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  disable_api_termination     = false

  user_data = <<-EOF
    #!/bin/bash
    cat > /opt/csye6225/.env << 'ENVFILE'
    PORT=${var.app_port_env}
    DB_HOST=${var.db_host}
    DB_PORT=5432
    DB_USER=${var.db_username}
    DB_PASSWORD=${var.db_password}
    DB_NAME=${var.db_name}
    JWT_SECRET=changeme
    NODE_ENV=production
    ENVFILE
    chown csye6225:csye6225 /opt/csye6225/.env
    systemctl restart webapp
  EOF

  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project}-${var.env}-${var.name_suffix}-app"
  }
}