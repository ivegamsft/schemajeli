output "backend_app_id" {
  description = "Backend App Service ID"
  value       = azurerm_linux_web_app.backend.id
}

output "backend_app_name" {
  description = "Backend App Service name"
  value       = azurerm_linux_web_app.backend.name
}

output "backend_default_hostname" {
  description = "Backend App Service default hostname"
  value       = azurerm_linux_web_app.backend.default_hostname
}

output "principal_id" {
  description = "Managed identity principal ID"
  value       = azurerm_linux_web_app.backend.identity[0].principal_id
}

output "service_plan_id" {
  description = "App Service Plan ID"
  value       = azurerm_service_plan.main.id
}
