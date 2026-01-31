output "server_id" {
  description = "PostgreSQL server ID"
  value       = azurerm_postgresql_flexible_server.main.id
}

output "server_fqdn" {
  description = "PostgreSQL server FQDN"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "database_id" {
  description = "PostgreSQL database ID"
  value       = azurerm_postgresql_flexible_server_database.main.id
}

output "database_name" {
  description = "PostgreSQL database name"
  value       = azurerm_postgresql_flexible_server_database.main.name
}

output "admin_username" {
  description = "PostgreSQL admin username"
  value       = azurerm_postgresql_flexible_server.main.administrator_login
}

output "admin_password" {
  description = "PostgreSQL admin password"
  value       = var.admin_password != "" ? var.admin_password : random_password.postgres.result
  sensitive   = true
}

output "connection_string" {
  description = "PostgreSQL connection string"
  value       = "postgresql://${azurerm_postgresql_flexible_server.main.administrator_login}:${var.admin_password != "" ? var.admin_password : random_password.postgres.result}@${azurerm_postgresql_flexible_server.main.fqdn}:5432/${azurerm_postgresql_flexible_server_database.main.name}"
  sensitive   = true
}
