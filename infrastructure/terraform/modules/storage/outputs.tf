output "storage_account_id" {
  description = "Storage Account ID"
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "Storage Account name"
  value       = azurerm_storage_account.main.name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "primary_connection_string" {
  description = "Primary connection string"
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}

output "storage_account_sas_token" {
  description = "Storage Account SAS token"
  value       = data.azurerm_storage_account_sas.main.sas
  sensitive   = true
}

output "uploads_container_name" {
  description = "Uploads container name"
  value       = azurerm_storage_container.uploads.name
}

output "exports_container_name" {
  description = "Exports container name"
  value       = azurerm_storage_container.exports.name
}

output "backups_container_name" {
  description = "Backups container name"
  value       = azurerm_storage_container.backups.name
}
