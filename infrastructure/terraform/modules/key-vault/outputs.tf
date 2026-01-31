output "key_vault_id" {
  description = "Key Vault ID"
  value       = azurerm_key_vault.main.id
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.main.vault_uri
}

output "database_secret_id" {
  description = "Database connection string secret ID"
  value       = azurerm_key_vault_secret.database_connection_string.id
}

output "jwt_secret_id" {
  description = "JWT secret ID"
  value       = azurerm_key_vault_secret.jwt_secret.id
}
