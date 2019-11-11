output "app_external_ip" {
  value = module.app.app_external_ip
}
output "db_addr" {
  value = module.db.internal_ip
}
output "db_external_ip" {
  value = module.db.db_external_ip
}
