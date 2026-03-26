resource "aws_launch_template" "app" {
  name          = "csye6225_asg"
  image_id      = var.custom_ami_id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.main.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app_sg.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(<<-USERDATA
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
  sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s
  systemctl restart webapp
  USERDATA
  )

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 25
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  tags = {
    Name = "${var.project}-${var.env}-${var.name_suffix}-launch-template"
  }
}

resource "aws_autoscaling_group" "app" {
  name                = "${var.project}-${var.env}-${var.name_suffix}-asg"
  min_size            = 3
  max_size            = 5
  desired_capacity    = 3
  default_cooldown    = 60
  vpc_zone_identifier = aws_subnet.public[*].id

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app.arn]

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.env}-${var.name_suffix}-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "AutoScalingGroup"
    value               = "${var.project}-${var.env}-${var.name_suffix}-asg"
    propagate_at_launch = true
  }

  wait_for_capacity_timeout = "0"

  depends_on = [aws_db_instance.postgres]
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.project}-${var.env}-${var.name_suffix}-scale-up"
  autoscaling_group_name = aws_autoscaling_group.app.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project}-${var.env}-${var.name_suffix}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 5
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.project}-${var.env}-${var.name_suffix}-scale-down"
  autoscaling_group_name = aws_autoscaling_group.app.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.project}-${var.env}-${var.name_suffix}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 3
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
}
