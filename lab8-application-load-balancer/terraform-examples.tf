# Terraform Examples for Application Load Balancer
# Optional reference for Infrastructure as Code approach

# Target Group
resource "aws_lb_target_group" "web_tg" {
  name     = "USERNAME-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = {
    Name = "USERNAME-web-tg"
    Lab  = "Lab8-ALB"
  }
}

# Application Load Balancer
resource "aws_lb" "web_alb" {
  name               = "USERNAME-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "USERNAME-web-alb"
    Lab  = "Lab8-ALB"
  }
}

# ALB Listener
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# Target Group Attachments
resource "aws_lb_target_group_attachment" "web_servers" {
  count            = length(var.instance_ids)
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = var.instance_ids[count.index]
  port             = 80
}

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name_prefix = "USERNAME-alb-sg"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "USERNAME-alb-sg"
    Lab  = "Lab8-ALB"
  }
}

