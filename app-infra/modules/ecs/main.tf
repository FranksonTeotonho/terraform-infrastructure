#===============================================
# Private subnets
#===============================================
data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "tag:type"
    values = ["Private"]
  }
}

#===============================================
# ECS Cluster
#===============================================
resource "aws_ecs_cluster" "my_cluster" {
  name = "${var.env}_ecs_cluster"

  tags = {
    env        = var.env,
    managed_by = "Terraform"
  }
}

#===============================================
# ECS Task Definition
# - Fargate provides a self-managed cluster
# - The network mode awsvpc allow us to use VPC resources such as SGs and Subnets
# - For simplicity, our container will consumes the memory and cpu provided by the task
#===============================================
resource "aws_ecs_task_definition" "my_task_definition" {
  family                   = "${var.env}_task_definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory

  # Templates allow us to use the same file for different environments
  container_definitions = jsonencode([{
    name        = "simple-api",
    image       = "franksonteotonho/simple-api:${var.app_version}"
    cpu         = var.cpu,
    memory      = var.memory,
    essential   = true,
    environment = [{ name = "ENV", value = "${var.env}" }],
    portMappings = [
      {
        containerPort = 8080,
        hostPort      = 8080
      }
    ]
  }])

  tags = {
    env        = var.env,
    managed_by = "Terraform"
  }
}

#===============================================
# ECS Service
# - Number of nodes can be defined when calling the module, it can be different per environment
# - Services / Tasks are spread in different private subnets
# - SGs are defined by environment, I made it a variable to allow attachment of new SGs
# - Load balancer is set in the module call
#===============================================
resource "aws_ecs_service" "my_service" {
  name            = "${var.env}_service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task_definition.arn
  desired_count   = var.number_of_nodes
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = var.security_groups_ids
    subnets          = data.aws_subnets.private_subnets.ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_lb_arn
    container_name   = "simple-api"
    container_port   = 8080
  }
}
