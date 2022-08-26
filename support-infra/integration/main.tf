#---------------------------------
# Network infrastructure para o ambiente de Integration
# - Os modulos podem ser reutilizados para a criação de mais ambientes como Staging e Production.
# - O projeto contem a infraestrutura de rede VPC, Subnets, IGW, Route Tables, SGs e etc.
# - Decidi criar um projeto separado para a infraestrutura de rede porque apesar de estar relacionado ao projeto,
# pode ser utilizados por eventuais outros projetos.
# - Usar VPCs para isolar ambientes (int, stag e prod) faz mais sentido que isolar projetos.
# Talvez até criar accounts diferentes para cada ambiente e garantir o isolamento de projetos por meio de IAMs, SGs e etc.
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
# Network infrastructure
#---------------------------------
module "my_network_infra" {
  source = "../modules/network"
  env    = var.env
}

#---------------------------------
# Security Groups
# - Contem os SGs para o ECS e para o Load Balancer
# - Apenas as portas em uso são abertas, com exceção do outbound do ECS que conta com a proteção de uma NAT.
#---------------------------------
module "sg_modules" {
  source     = "../modules/security_groups"
  env        = var.env
  vpc_id     = module.my_network_infra.vpc_id
  depends_on = [module.my_network_infra]
}