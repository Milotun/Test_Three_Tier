output "this_lb_dns_name" {
  value = module.compute.lb_dns_name
}

output "db_password" {
  value = module.database.db_config.password
  sensitive = true
}