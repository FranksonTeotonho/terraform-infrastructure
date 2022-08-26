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
# Network infrastructure
#---------------------------------
module "my_network_infra" {
  source = "../modules/network"
  env    = var.env
}

#---------------------------------
# Security Groups
#---------------------------------
module "sg_modules" {
  source     = "../modules/security_groups"
  env        = var.env
  depends_on = [module.my_network_infra]
}