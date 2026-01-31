output "static_site_id" {
  description = "Static Web App ID"
  value       = azurerm_static_site.frontend.id
}

output "static_site_name" {
  description = "Static Web App name"
  value       = azurerm_static_site.frontend.name
}

output "default_host_name" {
  description = "Default hostname of the Static Web App"
  value       = azurerm_static_site.frontend.name
}

output "api_key" {
  description = "Static Web App deployment token"
  value       = azurerm_static_site.frontend.api_key
  sensitive   = true
}
