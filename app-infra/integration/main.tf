terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

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
# Data source - Load Balancer SG
#---------------------------------
data "aws_security_group" "lb_sg" {
  name = "${var.env}-lb-sg"
}

#---------------------------------
# Data source - ECS SG
#---------------------------------
data "aws_security_group" "ecs_sg" {
  name = "${var.env}-ecs-sg"
}

#---------------------------------
# Load Balancer Module
#---------------------------------
module "lb" {
  source              = "../modules/load_balancer"
  env                 = var.env
  vpc_id              = data.aws_vpc.selected_vpc.id
  security_groups_ids = [data.aws_security_group.lb_sg.id]
}

#---------------------------------
# ECS Module
#---------------------------------
module "ecs" {
  source              = "../modules/ecs"
  env                 = var.env
  vpc_id              = data.aws_vpc.selected_vpc.id
  security_groups_ids = [data.aws_security_group.ecs_sg.id]
  target_group_lb_arn = module.lb.ecs_lb_target_group_arn
  app_version         = var.app_version
  number_of_nodes     = var.number_of_nodes
  cpu                 = var.cpu
  memory              = var.memory
}

#---------------------------------
# S3 Web site
#---------------------------------
module "s3_web_site" {
  source  = "../modules/s3"
  env     = var.env
  api_url = "http://${module.lb.lb_dns}/api"
}

#---------------------------------
# CloudFront
#---------------------------------
module "cloudfront" {
  source                         = "../modules/cloudfront"
  env                            = var.env
  s3_bucket_id                   = module.s3_web_site.s3_bucket_id
  s3_bucket_arn                  = module.s3_web_site.s3_bucket_arn
  s3_bucket_regional_domain_name = module.s3_web_site.s3_bucket_regional_domain_name
  lb_dns                         = module.lb.lb_dns
}