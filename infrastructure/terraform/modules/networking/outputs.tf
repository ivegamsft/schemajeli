output "vnet_id" {
  description = "Virtual Network ID"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Virtual Network name"
  value       = azurerm_virtual_network.main.name
}

output "app_subnet_id" {
  description = "App subnet ID"
  value       = azurerm_subnet.app.id
}

output "database_subnet_id" {
  description = "Database subnet ID"
  value       = azurerm_subnet.database.id
}

output "app_nsg_id" {
  description = "App NSG ID"
  value       = azurerm_network_security_group.app.id
}

output "database_nsg_id" {
  description = "Database NSG ID"
  value       = azurerm_network_security_group.database.id
}
