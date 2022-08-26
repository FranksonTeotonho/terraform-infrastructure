#---------------------------------
# Application infrastructure para o ambiente de Integration
# - Os modulos podem ser reutilizados para a criação de mais ambientes como Staging e Production.
# - O projeto utiliza recursos previamente criados no support-infra
#---------------------------------
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
  region  = var.aws_region
  profile = "terraform_user"
}

#---------------------------------
# Data source - VPC
# Busca a VPC já criada e deixa disponivel no projeto
#---------------------------------
data "aws_vpc" "selected_vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.env}-vpc"]
  }
}

#---------------------------------
# Data source - Load Balancer SG
# Busca o SG já criada e deixa disponivel no projeto
#---------------------------------
data "aws_security_group" "lb_sg" {
  name = "${var.env}-lb-sg"
}

#---------------------------------
# Data source - ECS SG
# Busca o SG já criada e deixa disponivel no projeto
#---------------------------------
data "aws_security_group" "ecs_sg" {
  name = "${var.env}-ecs-sg"
}

#---------------------------------
# Load Balancer Module
# - Application load balancer com um target para ser usado com o ECS
#---------------------------------
module "lb" {
  source              = "../modules/load_balancer"
  env                 = var.env
  vpc_id              = data.aws_vpc.selected_vpc.id
  security_groups_ids = [data.aws_security_group.lb_sg.id]
}

#---------------------------------
# ECS Module
# - ECS Cluter, Task Definition e Service. Utiliza Fargat.
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
# - S3 Bucket private, S3 objects com o site static (HTML e JavaScript)
#---------------------------------
module "s3_web_site" {
  source  = "../modules/s3"
  env     = var.env
  api_url = "http://${module.lb.lb_dns}/api"
}

#---------------------------------
# CloudFront
# - Cria CloudFront distribution com rotas para o frontend(/) e backend (/api)
# - Cria ACL para acesso do s3 bucket
#---------------------------------
module "cloudfront" {
  source                         = "../modules/cloudfront"
  env                            = var.env
  s3_bucket_id                   = module.s3_web_site.s3_bucket_id
  s3_bucket_arn                  = module.s3_web_site.s3_bucket_arn
  s3_bucket_regional_domain_name = module.s3_web_site.s3_bucket_regional_domain_name
  lb_dns                         = module.lb.lb_dns
}