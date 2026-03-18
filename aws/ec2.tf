resource "aws_instance" "app" {
  ami                         = var.custom_ami_id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.main.key_name
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  disable_api_termination     = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
  #!/bin/bash
  cat > /opt/csye6225/.env << ENVFILE
  PORT=3000
  DB_HOST=${aws_db_instance.postgres.address}
  DB_PORT=5432
  DB_USER=${aws_db_instance.postgres.username}
  DB_PASSWORD=${var.db_master_password}
  DB_NAME=${aws_db_instance.postgres.db_name}
  JWT_SECRET=${var.jwt_secret}
  NODE_ENV=production
  S3_BUCKET_NAME=${aws_s3_bucket.app.bucket}
  AWS_REGION=${var.aws_region}
  ENVFILE
  chown csye6225:csye6225 /opt/csye6225/.env

  # Configure and start CloudWatch agent
  sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s

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

  depends_on = [aws_db_instance.postgres]
}