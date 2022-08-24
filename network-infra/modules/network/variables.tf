#---------------------------------
# Stack variables
#---------------------------------
variable "env" {}

#---------------------------------
# VPC variables
#---------------------------------
variable "vpc_cidr_block" {
  default = "172.32.0.0/16"
}

#---------------------------------
# Public subnet variables
#---------------------------------
variable "number_of_public_subnets" {
  default = 3
}
variable "public_subnets_cidr" {
  type    = list
  default = ["172.32.1.0/24", "172.32.2.0/24", "172.32.3.0/24"]
}

#---------------------------------
# Private subnet variables
#---------------------------------
variable "number_of_private_subnets" {
  default = 3
}
variable "privates_subnets_cidr" {
  type    = list
  default = ["172.32.4.0/24", "172.32.5.0/24", "172.32.6.0/24"]
}