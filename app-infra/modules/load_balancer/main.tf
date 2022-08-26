#===============================================
# Public subnets
#===============================================
data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "tag:type"
    values = ["Public"]
  }
}

#===============================================
# Application Load Balancer
#===============================================
resource "aws_lb" "app_lb" {
  name               = "${var.env}-app-lb"
  load_balancer_type = "application"
  security_groups    = var.security_groups_ids
  subnets            = data.aws_subnets.public_subnets.ids

  tags = {
    env        = var.env,
    managed_by = "Terraform"
  }

  # After creation do not change subnets, it will force the recreation of the LB
  lifecycle {
    ignore_changes = [subnets]
  }
}

#===============================================
# Load Balancer Listener
#===============================================
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
  }
}

#===============================================
# ECS Target Group
#===============================================
resource "aws_lb_target_group" "ecs_target_group" {
  name        = "${var.env}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    port = 8080
    path = "/api"
  }
}