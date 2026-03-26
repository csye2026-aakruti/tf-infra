resource "aws_lb" "app" {
  name               = "${var.project}-${var.env}-${var.name_suffix}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.public[*].id
  tags = {
    Name = "${var.project}-${var.env}-${var.name_suffix}-alb"
  }
}

resource "aws_lb_target_group" "app" {
  name     = "${var.project}-${var.env}-${var.name_suffix}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id

  health_check {
    path                = "/healthz"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
