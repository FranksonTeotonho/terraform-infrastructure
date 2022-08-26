#---------------------------------
# Data source - VPC
#---------------------------------
data "aws_vpc" "selected_vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.env}-vpc"]
  }
}
#---------------------------------
# SG - Load Balancer
#---------------------------------
resource "aws_security_group" "lb_sg" {
  name   = "${var.env}-lb-sg"
  vpc_id = data.aws_vpc.selected_vpc.id

  tags = {
    env        = var.env
    managed_by = "Terraform"
  }
}

# Inbound
resource "aws_security_group_rule" "lb_sg_http_inbound" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb_sg.id
}

# Outbound
resource "aws_security_group_rule" "lb_sg_http_outbound" {
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.ecs_sg.id
  security_group_id        = aws_security_group.lb_sg.id
}

#---------------------------------
# SG - ECS
#---------------------------------
resource "aws_security_group" "ecs_sg" {
  name   = "${var.env}-ecs-sg"
  vpc_id = data.aws_vpc.selected_vpc.id

  tags = {
    env        = var.env
    managed_by = "Terraform"
  }
}

# Inbound
resource "aws_security_group_rule" "ecs_sg_http_inbound" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.lb_sg.id
  security_group_id        = aws_security_group.ecs_sg.id
}

# Outbound
resource "aws_security_group_rule" "ecs_sg_http_outbound" {
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_sg.id
}