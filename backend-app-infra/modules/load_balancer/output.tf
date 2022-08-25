output "ecs_lb_target_group_arn" {
  value = aws_lb_target_group.ecs_target_group.arn
}

output "lb_dns" {
  value = aws_lb.app_lb.dns_name
}