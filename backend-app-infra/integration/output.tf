output "frontend_url" {
  value = "http://${module.cloudfront.cloudfront_domain_name}/"
}

output "backend_url" {
  value = "http://${module.cloudfront.cloudfront_domain_name}/api"
}