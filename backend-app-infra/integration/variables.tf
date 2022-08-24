variable "aws_region" {
  default = "us-east-1"
}

variable "env" {
  default = "int"
}

variable "app_version" {
  default = "latest"
}

variable "number_of_nodes" {
  default = 2
}

variable "cpu" {
  default = 1024
}

variable "memory" {
  default = 2048
}