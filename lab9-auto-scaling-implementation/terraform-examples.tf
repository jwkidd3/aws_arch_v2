# Terraform Examples for Auto Scaling (Advanced Reference)
# Optional reference for Infrastructure as Code approach

# Launch Template
resource "aws_launch_template" "asg_template" {
  name_prefix   = "USERNAME-asg-template"
  image_id      = "ami-0abcdef1234567890"  # Amazon Linux 2023
  instance_type = "t2.micro"
  key_name      = var.key_pair_name

  vpc_security_group_ids = [aws_security_group.asg_sg.id]

  user_data = base64encode(templatefile("user_data.sh", {
    username = var.username
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "USERNAME-asg-instance"
      Lab  = "Lab9-AutoScaling"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                = "USERNAME-asg"
  vpc_zone_identifier = var.public_subnet_ids
  target_group_arns   = [aws_lb_target_group.asg_tg.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = 1
  max_size         = 6
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.asg_template.id
    version = "$Latest"
  }

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  tag {
    key                 = "Name"
    value               = "USERNAME-asg"
    propagate_at_launch = false
  }
}

# Auto Scaling Policy
resource "aws_autoscaling_policy" "target_tracking" {
  name               = "USERNAME-target-tracking-policy"
  scaling_adjustment = 4
  policy_type        = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.main.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}

# Load Balancer Target Group
resource "aws_lb_target_group" "asg_tg" {
  name     = "USERNAME-asg-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }
}

# Application Load Balancer
resource "aws_lb" "asg_alb" {
  name               = "USERNAME-asg-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.asg_sg.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false
}

# Load Balancer Listener
resource "aws_lb_listener" "asg_listener" {
  load_balancer_arn = aws_lb.asg_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg_tg.arn
  }
}

