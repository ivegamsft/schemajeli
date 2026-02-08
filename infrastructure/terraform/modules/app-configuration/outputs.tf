output "app_configuration_id" {
  description = "App Configuration resource ID"
  value       = azurerm_app_configuration.main.id
}

output "app_configuration_name" {
  description = "App Configuration name"
  value       = azurerm_app_configuration.main.name
}

output "app_configuration_endpoint" {
  description = "App Configuration endpoint"
  value       = azurerm_app_configuration.main.endpoint
}
