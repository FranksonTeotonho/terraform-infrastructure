variable "vpc_id" {}
variable "security_groups_ids" {}
variable "target_group_lb_arn" {}

variable "env" {}
variable "app_version" {}
variable "number_of_nodes" {}

# If not explicitly set, use prod default for cpu and memory
variable "cpu" {
  default = 2048
}

variable "memory" {
  default = 4096
}